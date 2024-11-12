import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_dart_fclay/api/notes.dart';
import 'package:my_dart_fclay/api/server_synced_r_e_s_t_markdown_editor_controller.dart';
import 'package:my_dart_fclay/gui/mdeditor.dart';

class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  int selectedTabIndex = 0;
  Future<List<TabItem>> future = fetchTabs();
  late List<TabItem> tabs;

  late MarkdownEditorController controller;
  late dynamic mdpage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: FutureBuilder<List<TabItem>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            } else {
              tabs = snapshot.data!;
              if (tabs.isNotEmpty) {
                controller = ServerSyncedRESTMarkdownEditorController(
                    tabs[selectedTabIndex].accessToken);
                mdpage = MarkdownEditorPage(controller);
              } else {
                mdpage = Text("No tabs...");
              }
              return Column(children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(children: [
                        ...snapshot.data!.map((tab) {
                          final int index =
                              snapshot.data!.indexOf(tab); // Сохраняем индекс
                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedTabIndex = index;
                                print("selectedTabIndex=$selectedTabIndex");
                                print(mdpage);
                              });
                            },
                            onLongPress: () {
                              _deleteNoteConfirm(tabs, tab);
                            },
                            child: Text(
                              tab.name,
                              style: TextStyle(
                                color: index == selectedTabIndex
                                    ? Color.fromARGB(255, 5, 246, 33)
                                    : null,
                              ),
                            ),
                          );
                        }),
                      ]),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _addNewNote(
                          snapshot.data!), // Обработка нажатия кнопки "+"
                    ),
                  ],
                ),
                Expanded(
                  child: mdpage,
                ),
              ]);
            }
          }),
    );
  }

  void _addNewNote(List<TabItem> tabs) {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String token = '';
        return AlertDialog(
          title: Text('Добавить новую заметку'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Название'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Токен'),
                onChanged: (value) {
                  token = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (title.isNotEmpty || token.isNotEmpty) {
                  setState(() {
                    tabs.add(TabItem(name: title, accessToken: token));
                    print(tabs);
                    future = postTabs(tabs);
                  });
                }
                Navigator.of(context).pop(); // Закрывает диалог
              },
              child: Text('Добавить'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрывает диалог без действия
              },
              child: Text('Отмена'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNoteConfirm(List<TabItem> tabs, TabItem tab) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Удалить вкладку?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tabs.remove(tab);
                  print(tabs);
                  future = postTabs(tabs);
                });
                Navigator.of(context).pop(); // Закрывает диалог
              },
              child: Text('Удалить'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрывает диалог без действия
              },
              child: Text('Отмена'),
            ),
          ],
        );
      },
    );
  }
}
