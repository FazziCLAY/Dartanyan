import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:my_dart_fclay/constants.dart';
import 'package:my_dart_fclay/gui/mdeditor.dart';

/// Контроллер MarkDownEditor'а который синхронизирован с сервером по Rest api
/// В конструкторе принимает accessToken для доступа
///
/// Также внутри содержит свой метод setState() который вызывает _stateChangeCallback,
/// а он по логике вызывает setState внутри Fluter GUI (виджера)
class ServerSyncedRESTMarkdownEditorController
    extends MarkdownEditorController {
  final _l = Logger(level: debug ? Level.debug : Level.warning);

  // bind states
  late TextEditingController _textController;
  late MarkdownEditorState _state;
  late OnStateChangedCallback _stateChangeCallback;

  // accessToken
  String accessToken;

  // flags
  bool disposed = false;
  bool firstRun = true;
  bool initialized = false;

  // misc
  late dynamic
      textControllerListener; // keep listener for delete it at dispose();
  int latestEditServer = 0;
  int latestEditCurrent = 0;
  String? currentTextInternal;
  int notesSyncingStartTime = -2;
  bool updatingFromServer = false;
  bool locked_real = false;
  Timer? syncingTimer;
  Timer? lockingTimer;

  // constructor
  ServerSyncedRESTMarkdownEditorController(this.accessToken);

  // Initialize states (bindme to MarkDownEditor)
  @override
  void initState(
      MarkdownEditorState state,
      TextEditingController textController,
      OnStateChangedCallback stateChangeCallback) {
    if (initialized) {
      throw Exception("This Contoller already initialized...");
    }
    initialized = true;
    if (disposed) {
      throw Exception("This Contoller disposed...");
    }

    _state = state;
    _textController = textController;
    _stateChangeCallback = stateChangeCallback;

    // clear state & textController from previous sessions;
    freshBind();
    _state.loading = true;

    _textController.addListener(textControllerListener = () {
      if (currentTextInternal != _textController.text &&
          !_state.locked &&
          !_state.loading) {
        currentTextInternal = _textController.text;
        latestEditCurrent = DateTime.now().millisecondsSinceEpoch;
        setState(() {}); // <--- setState() => updateColor()
      }
    });
    startInit();
  }

  @override
  void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
    freshBind();
    _textController.removeListener(textControllerListener);
    syncingTimer?.cancel();
    lockingTimer?.cancel();
  }

  // Custom setState
  // it method call argument lambda, next updateColor(); and call _stateChangeCallback for see it's in gui;
  void setState(void Function() func) {
    func.call();
    updateColor();
    _stateChangeCallback.call();
  }

  // only recalc _state.color var
  void updateColor() {
    _state.color = _state.loading
        ? Color.fromARGB(255, 255, 3, 3)
        : (_state.locked
            ? Color.fromARGB(255, 120, 120, 120)
            : (isAsInServer()
                ? Color.fromARGB(255, 51, 255, 0)
                : Color.fromARGB(255, 255, 153, 0)));
  }

  // cleanup oldest states from previous Controller on this MarkdownEditor
  // this method should be changes only 'bind' variables (vars set's in initState() created outside)
  void freshBind() {
    _state.color = null;
    _state.loading = false;
    _state.locked = false;
    _state.error = null;
    _textController.text = "";
  }

  // set text to gui (check if text diff);
  void setText(String s, int editTime, {bool patchServer = false}) {
    _l.i("setText(); s=$s");
    if (s != _textController.text) {
      _textController.text = s;
      currentTextInternal = s;
    }
    latestEditCurrent = editTime;
    if (patchServer) {
      latestEditServer = editTime;
    }
  }

  // called once at TAIL of initState();
  void startInit() {
    _l.i("startInit();");
    startSyncingTimer();
    startLockingTimer();
  }

  // logical: set locked state
  set locked(bool b) {
    if (locked_real != b || b != _state.locked) {
      locked_real = b;
      setState(() {
        _state.locked = b;
      });
    }
  }

  set error(dynamic err) {
    if (_state.error != err) {
      setState(() {
        _state.error = err;
      });
    }
  }

  // REWRITTEN FROM REACT APP
  // set is currently syncing... (true)
  void setNotesIsSyncing(bool syncing) {
    if (syncing) {
      notesSyncingStartTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      notesSyncingStartTime = -1;
    }
  }

  // REWRITTEN FROM REACT APP
  // is currently syncing
  bool notesIsSyncing() => notesSyncingStartTime > 0;

  // return: "current state as in server?"
  bool isAsInServer() => latestEditCurrent == latestEditServer;

  // REWRITTEN FROM REACT APP
  // Receive full json from server
  void fromServer(Map json) {
    if (latestEditCurrent < notesSyncingStartTime - 1500) {
      var leSrv = json['latestEdit'];
      print(json);
      if (leSrv != latestEditServer) {
        setText(json['text'], leSrv, patchServer: true);
        if (firstRun) {
          _state.loading = false;
          firstRun = false;
        }
      }
    } else {
      print(
          'l > 1500; notes edited after fetch start. skip result of this fetch.');
    }
    setState(() {});
    setNotesIsSyncing(false);
  }

  // REWRITTEN FROM REACT APP
  // fetch notes from API
  Future<void> fetchNotes([bool full = false]) async {
    setNotesIsSyncing(true);
    if (full) updatingFromServer = true; // <---- full updating flag

    final response = await http.get(
        Uri.parse('$apiUrl/notes${full ? '' : '?specKeys=latestEdit,l'}'),
        headers: {
          'Authorization': accessToken,
        });

    error = response.statusCode == 200
        ? null
        : "fetchNotes: HTTP CODE: ${response.statusCode}\nBODY: ${response.body}";
    if (response.statusCode != 200) {
      _l.w(
          'HTTP ERROR WHILE PARSING NOTES: ${response.statusCode}: ${response.body}');
      return;
    }

    Map json = jsonDecode(response.body);

    if (full) {
      fromServer(json);
      updatingFromServer = false; // <---- full updating flag
    } else {
      if (json['latestEdit'] != latestEditServer) {
        fetchNotes(true);
      } else {
        setNotesIsSyncing(false);
      }
      locked = (json['l'] == 1) && isAsInServer();
    }
  }

  // REWRITTEN FROM REACT APP
  // send current note text to server
  Future<void> syncNotes() async {
    setNotesIsSyncing(true);
    final response = await http.patch(
      Uri.parse('$apiUrl/notes'),
      headers: {
        'Authorization': accessToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': _textController.text,
      }),
    );

    error = response.statusCode == 200
        ? null
        : "sendNotes: HTTP CODE: ${response.statusCode}\nBODY: ${response.body}";
    if (response.statusCode == 200) {
      fromServer(jsonDecode(response.body));
    } else {
      _l.w(
          'HTTP ERROR WHILE PARSING NOTES: ${response.statusCode}: ${response.body}');
      setNotesIsSyncing(false);
    }
  }

  // REWRITTEN FROM REACT APP
  // send lock note signal to server
  Future<void> sendLocked() async {
    _l.d("sendLocked();");
    await http.post(Uri.parse('$apiUrl/notes/lock'), headers: {
      'Authorization': accessToken,
    });
  }

  // REWRITTEN FROM REACT APP
  void startSyncingTimer() {
    _l.d("sendLocstartSyncingTimerked();");
    syncingTimer?.cancel();
    syncingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!notesIsSyncing() && !isAsInServer()) {
        syncNotes();
      } else {
        fetchNotes(false);
      }
    });
  }

  // REWRITTEN FROM REACT APP
  void startLockingTimer() {
    _l.d("startLockingTimer();");
    lockingTimer?.cancel();
    lockingTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!notesIsSyncing() && latestEditCurrent != latestEditServer) {
        if ((DateTime.now().millisecondsSinceEpoch - latestEditCurrent) < 300) {
          sendLocked();
        }
      }
    });
  }
}
