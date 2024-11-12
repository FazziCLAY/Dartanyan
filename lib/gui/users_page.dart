import 'package:flutter/material.dart';
import 'package:my_dart_fclay/api/usersapi.dart';
import '../api/dto/user_dto.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder<List<UserDto>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data;

          return ListView.builder(
            itemCount: users?.length ?? 0,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(users![index].username),
                subtitle: Text('ID: ${users[index].id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Обработчик нажатия для добавления пользователя
          _showAddUserDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    bool isObscured = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить пользователя'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(isObscured
                          ? Icons.visibility
                          : Icons.visibility_off),
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
              child: const Text('Добавить'),
              onPressed: () async {
                final response = await addNewUser(
                    usernameController.text, passwordController.text);

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Пользователь добавлен')));
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
}
