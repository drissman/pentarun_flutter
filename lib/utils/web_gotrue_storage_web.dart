// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:gotrue/gotrue.dart';

// SPEC-KIT §3.1 ERRATA v2.1 — Remplace SharedPreferencesGotrueAsyncStorage
// SharedPreferences.setString hang sur Flutter Web (incognito ou proxy) avant
// la navigation OAuth PKCE. localStorage JS est synchrone → jamais bloqué.
class WebGotrueAsyncStorage extends GotrueAsyncStorage {
  @override
  Future<String?> getItem({required String key}) async {
    return html.window.localStorage[key];
  }

  @override
  Future<void> removeItem({required String key}) async {
    html.window.localStorage.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    html.window.localStorage[key] = value;
  }
}
