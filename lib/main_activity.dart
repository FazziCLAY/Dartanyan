import 'package:flutter/material.dart';
import 'notes_editor_logic.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});

  @override
  State<MainActivity> createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {

  late NotesEditorLogic notesEditorLogic;
  String textMutableStatus = "?";
  Color textMutableStatusColor = Colors.red;
  late TextEditingController textController; // Создайте переменную для контроллера
  String text = "";

  @override
  void initState() {
    super.initState();
    // Инициализируем логику заметок, передавая токен (например: 'your-auth-token')
    notesEditorLogic = NotesEditorLogic(
      token: '',
      onTextChanged: (updatedText) {
        print("activity: onTextChanged (labmda): text=$updatedText");
        //text = updatedText;
        if (textController.text != updatedText) {
          textController.text = updatedText;
        }
      },
    );
    notesEditorLogic.start();
    textController = TextEditingController(text: text); // Инициализируйте контроллер
  }

  @override
  void dispose() {
    notesEditorLogic.stop();
    textController.dispose(); // Освобождаем ресурс контроллера
    super.dispose();
  }

  void updateStatus() {
    setState(() {
      if (notesEditorLogic.serverEqual()) {
        textMutableStatus = "A";
        textMutableStatusColor = Colors.green;
      } else {
        textMutableStatus = "W";
        textMutableStatusColor = Color(0xFFF59703); // Замена на COLOR_WARNING
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                NotesTextArea(),
                NotesStateIndicator(),
                const SizedBox(height: 10)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget NotesStateIndicator() {
    return Text(
      textMutableStatus,
      style: TextStyle(color: textMutableStatusColor, fontSize: 18),
    );
  }

  Widget NotesTextArea() {
    return TextField(
      controller: textController, // Устанавливаем контроллер с текущим текстом
      maxLines: null,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.black),
        ),
        hintText: 'Введите заметку',
        contentPadding: EdgeInsets.all(10.0),
      ),
      style: TextStyle(fontSize: 14),
      onChanged: (newText) {
        print("newText=$newText");
        setState(() {
          text = newText; // Обновляем текст
        });
        notesEditorLogic.textBoxChanged(newText);
        updateStatus();
      },
    );
  }
}