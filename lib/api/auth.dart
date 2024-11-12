import 'package:http/http.dart';
import 'package:my_dart_fclay/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

var _l = Logger(level: debug ? Level.debug : Level.warning);

Future<Response> changePassword(String current, String newPassword) async {
  return http.post(
    Uri.parse('$apiUrl/auth/changePassword'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": await getToken()
    },
    body: json.encode({
      'old_password': current,
      'new_password': newPassword,
    }),
  );
}

/// Get current token (error if not loggined)
Future<String> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(sharedKeyAccessToken)!;
}

/// check is loggined
/// and try refrest accessToken
/// return: true if loginned, false if not;
Future<bool> checkLogin() async {
  final prefs = await SharedPreferences.getInstance();

  // CRUCNH START
  // set data version to 1
  await prefs.setInt(sharedKeyVersion, 1);
  // CRUNCH END

  _l.d("checkLogin();");
  String? accessToken = prefs.getString(sharedKeyAccessToken);

  if (accessToken != null && accessToken.trim().isNotEmpty) {
    if (accessToken == "skip") {
      return true;
    }
    final response = await http.post(apiAuthLoginUri, headers: {
      "Authorization": accessToken,
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 200) {
      _updateAuthLoginBody(response.body);
      return true;
    }

    _l.w("checkLogin(): ${response.statusCode} instead of http 200.");
    _l.d("body: ${response.body}");
    return (response.statusCode >= 200 && response.statusCode < 300) ||
        response.statusCode >= 500;
  }

  _l.d("checkLogin(): no accessToken set; logout and return false");
  await logout();
  return false;
}

/// update accessToken if 'accessToken' exist in body
Future<void> _updateAuthLoginBody(dynamic body) async {
  final b = json.decode(body);
  String? token = b['accessToken'];
  if (token != null) {
    await saveAccessToken(token);
  } else {
    _l.e("_updateAuthLoginBody(); accessToken not found in server response");
    _l.d("response=${body}");
  }
}

/// Try to login by username and passord
/// return: [(if success), (response body)]
Future<List<Object>> login(String username, String password) async {
  _l.d("login()");
  if (username == "skip") {
    saveAccessToken("skip");
    return List.of([true, "SKIP"]);
  }
  final response = await http.post(
    apiAuthLoginUri,
    headers: {'Content-Type': 'application/json'},
    body: '{"username": "$username", "password": "$password"}',
  );

  _l.d("response=${response.body}");
  if (debugAlwaysSuccessLogin || response.statusCode == 200) {
    // success login
    _updateAuthLoginBody(response.body);
    return List.of([true, response.body]);
  } else {
    // failed login
    return List.of([false, response.body]);
  }
}

/// logout (remove accessToken from SharedPreferences)
Future<void> logout() async {
  _l.d("logout()");
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(sharedKeyAccessToken); // Удаление логина при выходе
}

/// set accessToken to SharedPreferences (login directly)
Future<void> saveAccessToken(String token) async {
  _l.d("saveAccessToken()");
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(sharedKeyAccessToken, token);
}
