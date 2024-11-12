import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:markdown/markdown.dart' hide Text;

class MarkdownEditorState {
  Color? color;
  bool loading = false;
  bool locked = false;
  dynamic error;
}

typedef OnStateChangedCallback = void Function();

abstract class MarkdownEditorController {
  void initState(
      MarkdownEditorState state,
      TextEditingController textController,
      OnStateChangedCallback stateChangeCallback);
  void dispose();
}

class MarkdownEditorPage extends StatefulWidget {
  MarkdownEditorController controller;

  MarkdownEditorPage(this.controller, {super.key});

  @override
  State<MarkdownEditorPage> createState() {
    return _MarkdownEditorPageState();
  }
}

class _MarkdownEditorPageState extends State<MarkdownEditorPage> {
  final MarkdownEditorState _state = MarkdownEditorState();
  final TextEditingController _textController = TextEditingController();
  String markdownText = "";
  final ScrollController _scrollControllerEditor = ScrollController();
  final ScrollController _scrollControllerPreview = ScrollController();
  final FocusNode _focusNodeEditor = FocusNode();
  final FocusNode _focusNodeKeyboard = FocusNode();
  bool _isEditing = true;

  MarkdownEditorController get controller => widget.controller;

  double _editorScrollPosition = 0;
  double _previewScrollPosition = 0;

  @override
  void didUpdateWidget(MarkdownEditorPage oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.dispose();
      controller.initState(_state, _textController, () {
        setState(() {});
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();

    controller.initState(_state, _textController, () {
      setState(() {});
    });

    _textController.addListener(() {
      setState(() {
        markdownText = _textController.text;
      });
    });

    _scrollControllerEditor.addListener(() {
      _editorScrollPosition = _scrollControllerEditor.position.pixels;
    });

    _scrollControllerPreview.addListener(() {
      _previewScrollPosition = _scrollControllerPreview.position.pixels;
    });
  }

  void _toggleView() {
    if (_state.error != null) {
      return;
    }
    setState(() {
      _isEditing = !_isEditing;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditing) {
        FocusScope.of(context).requestFocus(_focusNodeEditor);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollControllerEditor.jumpTo(_editorScrollPosition);
        });
      } else {
        FocusScope.of(context).requestFocus(_focusNodeKeyboard);
        _scrollControllerPreview.jumpTo(_previewScrollPosition);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _textController.dispose();
    _scrollControllerEditor.dispose();
    _scrollControllerPreview.dispose();
    _focusNodeEditor.dispose();
    _focusNodeKeyboard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      onKeyEvent: (event) {
        if ((event is KeyDownEvent) &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          _toggleView();
        }
      },
      focusNode: _focusNodeKeyboard,
      child: Column(
        children: [
          Expanded(
            child: _isEditing && _state.error == null && !_state.loading
                ? SingleChildScrollView(
                    controller: _scrollControllerEditor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        readOnly: _state.locked || _state.loading,
                        controller: _textController,
                        focusNode: _focusNodeEditor,
                        onTap: () {
                          FocusScope.of(context).requestFocus(_focusNodeEditor);
                        },
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Введите markdown текст',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    controller: _scrollControllerPreview,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HtmlWidget(
                        markdownToHtml(_state.error == null ? (_state.loading ? "# Loading\nPlease wait..." : markdownText) : "# ERROR\n<span style=\"color:red\">${_state.error}</span>"),
                      ),
                    ),
                  ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                ElevatedButton(
                  onPressed: _toggleView,
                  child: Text(
                      _isEditing ? 'Показать Markdown' : 'Редактировать',
                      style: TextStyle(color: _state.color)),
                ),
                if (_state.loading) CircularProgressIndicator()
              ])),
        ],
      ),
    );
  }
}
