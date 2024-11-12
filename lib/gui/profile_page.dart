import 'package:flutter/material.dart'
    show
        AlertDialog,
        AppBar,
        BuildContext,
        Center,
        CircularProgressIndicator,
        Column,
        ConnectionState,
        ElevatedButton,
        FutureBuilder,
        Icon,
        IconButton,
        Icons,
        InputDecoration,
        MaterialPageRoute,
        Navigator,
        Scaffold,
        ScaffoldMessenger,
        SnackBar,
        State,
        StatefulWidget,
        Text,
        TextButton,
        TextEditingController,
        TextField,
        TextStyle,
        Widget,
        showDialog;
import 'package:flutter/widgets.dart';
import 'package:my_dart_fclay/api/auth.dart';
import 'package:my_dart_fclay/api/usersapi.dart';
import 'package:my_dart_fclay/api/dto/user_dto.dart';
import 'package:my_dart_fclay/gui/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String currentUser = "User"; // Имя текущего профиля

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выход'),
          content: const Text('Вы уверены, что хотите выйти?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: const Text('Выйти'),
                onPressed: () async {
                  await logout();
                  while (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                }),
          ],
        );
      },
    );
  }

  void _changePassword() {
    final oldPassController = TextEditingController();
    final passwordController = TextEditingController();
    final passwordController2 = TextEditingController();
    bool isObscured = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Изменить пароль'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: oldPassController,
                decoration: const InputDecoration(labelText: 'Текущий пароль'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                    labelText: 'Новый пароль (подтверждение)',
                    suffixIcon: IconButton(
                      icon: Icon(
                          isObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        isObscured = !isObscured; // Переключаем состояние
                      },
                    )),
                obscureText: isObscured,
              ),
              TextField(
                controller: passwordController2,
                decoration: InputDecoration(
                    labelText: 'Новый пароль (подтверждение)',
                    suffixIcon: IconButton(
                      icon: Icon(
                          isObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        isObscured = !isObscured; // Переключаем состояние
                      },
                    )),
                obscureText: isObscured,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Изменить'),
              onPressed: () async {
                if (passwordController.text != passwordController2.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Пароль не одинаковы')));
                  return;
                }
                // Ваша логика для добавления пользователя
                final response = await changePassword(
                    oldPassController.text, passwordController.text);

                if (response.statusCode == 204) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Пароль изменён.')));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: ${response.body}')));
                }
              },
            ),
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<UserDto>(
        future: fetchMySelf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final user = snapshot.data;

          return Center(
              child: Column(children: [
            Text(
              'Текущий пользователь: ${user?.username}',
              style: const TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () async => _changePassword(),
              child: const Text('Change password'),
            ),
          ]));
        },
      ),
    );
  }
}
