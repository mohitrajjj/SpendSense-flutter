import 'dart:async';
import 'package:localstorage/localstorage.dart';

class AuthHelper {
  static final LocalStorage _storage = LocalStorage('auth_data');
  static const String _userKey = 'userEmail';
  static const String _passwordKey = 'userPassword';
  static const String _nameKey = 'userName';
  static final StreamController<bool> _authStatusController =
      StreamController<bool>.broadcast();
  
  static String? _currentUserEmail;
  static String? _currentUserName;
  
  static get currentUserEmail => _currentUserEmail;
  static get currentUserName => _currentUserName;

  static Stream<bool> get authStatusStream => _authStatusController.stream;

  static Future<bool> isLoggedIn() async {
    await _storage.ready;
    final user = _storage.getItem(_userKey);
    final name = _storage.getItem(_nameKey);
    if (user != null) {
      _currentUserEmail = user;
      _currentUserName = name ?? user.split('@').first;
      return true;
    }
    return false;
  }

  static Future<void> login(String email, String password) async {
    await _storage.ready;
    await _storage.setItem(_userKey, email);
    await _storage.setItem(_passwordKey, password);
    _currentUserEmail = email;
    _currentUserName = email.split('@').first; // Default name on login
    await _storage.setItem(_nameKey, _currentUserName);
    _authStatusController.add(true);
  }

  static Future<void> logout() async {
    await _storage.ready;
    await _storage.deleteItem(_userKey);
    await _storage.deleteItem(_passwordKey);
    await _storage.deleteItem(_nameKey);
    _currentUserEmail = null;
    _currentUserName = null;
    _authStatusController.add(false);
  }

  static Future<bool> checkPassword(String password) async {
    await _storage.ready;
    final savedPassword = _storage.getItem(_passwordKey);
    return savedPassword == password;
  }

  static Future<void> changePassword(String newPassword) async {
    await _storage.ready;
    await _storage.setItem(_passwordKey, newPassword);
  }

  static Future<void> saveName(String newName) async {
    await _storage.ready;
    await _storage.setItem(_nameKey, newName);
    _currentUserName = newName;
  }

  static void dispose() {
    _authStatusController.close();
  }
}
