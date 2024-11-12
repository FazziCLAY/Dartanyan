import 'package:http/http.dart';
import 'package:my_dart_fclay/constants.dart';
import 'package:my_dart_fclay/api/auth.dart';
import 'package:my_dart_fclay/api/dto/user_dto.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// get current loggined user
Future<UserDto> fetchMySelf() async {
  String token = await getToken();
  final response = await http.get(Uri.parse('$apiUrl/users/me'), headers: {
    "Authorization": token,
  });

  if (response.statusCode == 200) {
    final dynamic userJson = json.decode(response.body);
    return UserDto.fromJson(userJson);
  } else {
    throw Exception('Failed to load myself user');
  }
}


// get all users (need permission)
Future<List<UserDto>> fetchUsers() async {
  String token = await getToken();
  final response = await http.get(Uri.parse('$apiUrl/users'), headers: {
    "Authorization": token,
  });

  if (response.statusCode == 200) {
    final List<dynamic> userJson = json.decode(response.body);
    return userJson.map((json) => UserDto.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}


// add new user (need permission)
Future<Response> addNewUser(String username, String password) async {
  // Ваша логика для добавления пользователя
  return await http.post(
    Uri.parse('$apiUrl/users/add'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": await getToken()
    },
    body: json.encode({
      'username': username,
      'password': password,
    }),
  );
}
