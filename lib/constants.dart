// constants.dart
const bool localhostApi = false;
const String apiUrl = localhostApi ? "http://192.168.0.223:8080" : "https://fazziclay.com/api/v1";
const String apiAuthLoginUrl = "$apiUrl/auth/login";
final Uri apiAuthLoginUri = Uri.parse(apiAuthLoginUrl);
const String sharedKeyVersion = "pf91dlr-version";
const String sharedKeyAccessToken = "4c26f341-accessToken";
const String sharedKeyNotesLocal = "1294i40-notesLocal";
const bool debug = true;
final bool debugMoreErrorsGui = deb(true);
final bool debugAlwaysSuccessLogin = deb(false);

bool deb(bool b) {
  return debug && b;
}

String dea(Object o) {
  if (debugMoreErrorsGui) {
    return "\n\n$o";
  }
  return "";
}