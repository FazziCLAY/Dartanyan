import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NoteDto {
  final String text;

  NoteDto(this.text);

  Map<String, dynamic> toJson() => {
        'text': text,
      };

  static NoteDto fromJson(Map<String, dynamic> json) {
    return NoteDto(json['text']);
  }
}

class NotesEditorLogic {
  final String _url = "https://fazziclay.com/api/v1/notes"; // Замените на актуальный адрес вашего API
  final String token; // Токен для аутентификации
  String textBoxText = '';
  String textFromServer = '';
  late Timer _timer;
  late Function(String) onTextChanged;
  
  NotesEditorLogic({required this.token, required this.onTextChanged});

  void start() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (_) => _interval());
  }

  void stop() {
    _timer.cancel();
  }

  void _interval() {
    // Устанавливаем логику отправки и получения данных
    if (textBoxText.isNotEmpty && (textFromServer != textBoxText)) {
      _sendNoteAreaToServer();
    }

    _setNoteFromServer();
  }

  Future<void> _setNoteFromServer() async {
    final response = await http.get(
      Uri.parse(_url),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final note = NoteDto.fromJson(json.decode(response.body));
      _overwriteNoteArea(note);
    } else {
      // Обработка ошибки
      print('Failed to load notes');
    }
  }

  void _overwriteNoteArea(NoteDto note) {
    print('_overwriteNoteArea note=$note');
    if (note.text.isNotEmpty) {
      textFromServer = note.text;
      onTextChanged(textFromServer);
    }
  }

  Future<void> _sendNoteAreaToServer() async {
    if (textBoxText.length < 1) return;

    final response = await http.patch(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: json.encode(NoteDto(textBoxText).toJson()),
    );

    if (response.statusCode == 200) {
      final note = NoteDto.fromJson(json.decode(response.body));
      _overwriteNoteArea(note);
    } else {
      print('Failed to send note');
    }
  }

  void textBoxChanged(String text) {
    textBoxText = text;
    onTextChanged(textBoxText);
  }

  bool serverEqual() {
    return textBoxText == textFromServer; // или используйте метод equals, если необходимо
  }
}