import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_dart_fclay/api/auth.dart';
import 'package:my_dart_fclay/constants.dart';

Future<List<TabItem>> fetchTabs() async {
  final response = await http.get(Uri.parse('$apiUrl/notes/tabs'),
      headers: {"Authorization": await getToken()});

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => TabItem.fromJson(item)).toList();
  } else {
    throw Exception('Не удалось загрузить вкладки: ${response.body}');
  }
}

Future<List<TabItem>> postTabs(List<TabItem> tabs) async {
  print(tabs);
  var body = json.encode(tabs);
  print("body=$body");
  final response = await http.post(Uri.parse('$apiUrl/notes/tabs'),
      headers: {
        "Authorization": await getToken(),
        'Content-Type': 'application/json'
      },
      body: body);

  print(response.body);
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => TabItem.fromJson(item)).toList();
  } else {
    throw Exception('Не удалось загрузить вкладки');
  }
}

// Модель для вкладок
class TabItem {
  final String name;
  final String accessToken;

  TabItem({required this.name, required this.accessToken});

  factory TabItem.fromJson(Map<String, dynamic> json) {
    return TabItem(
      name: json['name'],
      accessToken: json['accessToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'accessToken': accessToken};
  }
}

// LocalNoteStorage? localNoteStorage;

// class Note {
//   String title;
//   String text;
//   int latestEdit;

//   Note({
//     required this.title,
//     required this.text,
//     required this.latestEdit,
//   });

//   void edit(String nm) {
//     print("Note:edit();");
//     text = nm;
//     latestEdit = DateTime.now().millisecondsSinceEpoch;
//     save();
//   }

//   factory Note.fromJson(Map<String, dynamic> json) {
//     var noteText = json['text'] as String;
//     var latestEdit = json['latestEdit'];
//     var title = json['title'] as String;
//     return Note(title: title, text: noteText, latestEdit: latestEdit);
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'title': title,
//       'text': text,
//       'latestEdit': latestEdit,
//     };
//   }
// }

// class LocalNoteStorage {
//   List<Note> notes;
//   List<TabItem> tabs;

//   LocalNoteStorage({
//     required this.notes,
//     required this.tabs;
//   });

//   factory LocalNoteStorage.fromJson(Map<String, dynamic> json) {
//     var list = json['notes'] as List<dynamic>;
//     List<Note> parsedList =
//         List.from(list.map((i) => Note.fromJson(i)).toList(), growable: true);

//     return LocalNoteStorage(notes: parsedList);
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'notes': notes.map((note) => note.toJson()).toList(),
//     };
//   }
// }

// Future<LocalNoteStorage> init() async {
//   if (localNoteStorage != null) {
//     return localNoteStorage!;
//   }
//   print("Init(): ${json.encode(localNoteStorage)}");
//   var stror = await notesFromShared();
//   if (stror.isEmpty) {
//     localNoteStorage = LocalNoteStorage(notes: List.empty(growable: true));
//   } else {
//     localNoteStorage = LocalNoteStorage.fromJson(json.decode(stror));
//     save();
//   }
//   print(json.encode(localNoteStorage));
//   return localNoteStorage!;
// }

// Future<void> save() async {
//   print("Save(): ${json.encode(localNoteStorage)}");
//   if (localNoteStorage == null) {
//     return;
//   }
//   final prefs = await SharedPreferences.getInstance();
//   prefs.setString(sharedKeyNotesLocal, json.encode(localNoteStorage));
// }

// Future<String> notesFromShared() async {
//   final prefs = await SharedPreferences.getInstance();
//   if (!prefs.containsKey(sharedKeyNotesLocal)) {
//     return "";
//   }
//   return prefs.getString(sharedKeyNotesLocal)!;
// }
