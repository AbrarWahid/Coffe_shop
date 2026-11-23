import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON wrapper over SharedPreferences (localStorage on web).
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStore> open() async =>
      LocalStore(await SharedPreferences.getInstance());

  Map<String, Object?>? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map).cast<String, Object?>();
    } on FormatException {
      // Corrupt data should never brick the app; start fresh for this key.
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, Object?> value) =>
      _prefs.setString(key, jsonEncode(value));

  String? readString(String key) => _prefs.getString(key);

  Future<void> writeString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
}
