import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'local_store.dart';

class Account {
  const Account({required this.username, required this.email});

  final String username;
  final String email;

  String get displayName => username.isEmpty
      ? username
      : username[0].toUpperCase() + username.substring(1);
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Device-local accounts so the app is usable without a backend.
///
/// Passwords are stored only as salted SHA-256 hashes, but this is NOT a
/// substitute for server-side auth: swap this class for an API-backed
/// implementation before going to production.
class AuthRepository {
  AuthRepository(this._store);

  final LocalStore _store;

  static const _accountsKey = 'accounts';
  static const _sessionKey = 'session';

  Map<String, Object?> get _accounts => _store.readJson(_accountsKey) ?? {};

  static String normalize(String username) => username.trim().toLowerCase();

  Account? currentSession() {
    final username = _store.readString(_sessionKey);
    if (username == null) return null;
    final record = _accounts[username];
    return record is Map ? _toAccount(username, record) : null;
  }

  Future<Account> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final key = normalize(username);
    final accounts = _accounts;
    if (accounts.containsKey(key)) {
      throw const AuthException(
        'That username is taken. Try signing in instead.',
      );
    }
    final salt = _salt();
    accounts[key] = {
      'email': email.trim(),
      'salt': salt,
      'hash': _hash(password, salt),
    };
    await _store.writeJson(_accountsKey, accounts);
    await _store.writeString(_sessionKey, key);
    return Account(username: key, email: email.trim());
  }

  Future<Account> signIn({
    required String username,
    required String password,
  }) async {
    final key = normalize(username);
    final record = _accounts[key];
    if (record is! Map) {
      throw const AuthException('No account found with that username.');
    }
    if (_hash(password, record['salt'] as String) != record['hash']) {
      throw const AuthException('Incorrect password. Please try again.');
    }
    await _store.writeString(_sessionKey, key);
    return _toAccount(key, record);
  }

  Future<void> signOut() => _store.remove(_sessionKey);

  Account _toAccount(String username, Map record) =>
      Account(username: username, email: record['email'] as String? ?? '');

  static String _salt() {
    final rnd = Random.secure();
    return base64UrlEncode(List.generate(16, (_) => rnd.nextInt(256)));
  }

  static String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
