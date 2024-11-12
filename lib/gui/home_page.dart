import 'package:flutter/material.dart';
import 'package:my_dart_fclay/gui/notes_page.dart';
import 'package:my_dart_fclay/gui/profile_page.dart';
import 'package:my_dart_fclay/gui/users_page.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Home'),
      actions: <Widget>[
        PopupMenuButton<String>(
          // Меню, которое будет открываться по нажатию на кнопку с тремя точками.
          onSelected: (String result) {
            // Тут вы обрабатываете выбраное значение из меню.
            switch (result) {
              case 'users':
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const UsersPage()));
                break;

              case 'account':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()));
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'users',
              child: Text('Пользователи'),
            ),
            const PopupMenuItem<String>(
              value: 'account',
              child: Text('Аккаунт...'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MyAppBar(), body: NotesPage());
  }
}
