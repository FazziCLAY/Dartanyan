import 'package:flutter/material.dart';
import 'gui/home_page.dart';
import 'gui/login_page.dart';
import 'api/auth.dart';

var appColorScheeme = const ColorScheme.dark();

void main() {
  runApp(const AuthApp());
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color.fromARGB(255, 0, 255, 196), // This is a Color
        colorScheme: appColorScheeme,
      ),
      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!) {
            return HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
