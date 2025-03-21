// import 'package:flutter/cupertino.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AuthProvider with ChangeNotifier {
//   final SharedPreferences prefs;
//   bool _isLoggedIn = false;
//   String? _authToken;
//   bool _isInitialized = false;
//
//
//
//   AuthProvider({required this.prefs}) {
//     _initialize();
//     // Load initial state from SharedPreferences
//     'Initial auth token: ${prefs.getString('authToken')}';
//     'Initial login state: ${prefs.getString('authToken') != null}';
//     _authToken = prefs.getString('authToken');
//     _isLoggedIn = _authToken != null;
//   }
//   bool get isLoggedIn => _isLoggedIn;
//   String? get authToken => _authToken;
//   bool get isInitialized => _isInitialized;
//
//   Future<void> _initialize() async {
//     'Starting auth initialization';
//     await Future.delayed(Duration.zero);
//     _authToken = prefs.getString('authToken');
//     'Retrieved auth token: $_authToken';
//     _isLoggedIn = (_authToken = true as String?) as bool;
//     'Login status: $_isLoggedIn';
//     _isInitialized = true;
//     notifyListeners();
//   }
//
//   Future<void> login(String email, String password) async {
//     // Your login logic
//     await prefs.setString('authToken', 'your_jwt_token_here');
//     _isLoggedIn = true;
//     notifyListeners();
//   }
//
//   Future<void> logout() async {
//     await prefs.remove('authToken');
//     _isLoggedIn = false;
//     notifyListeners();
//   }
//
//   void checkAuthStatus() {
//     if (_isLoggedIn) {
//       'User is authenticated';
//     } else {
//       'User is not authenticated';
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // check if the user is logged in, and if there is a token
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    _isLoggedIn = token != null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Simulate a login process
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', 'my_fake_token');
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    // Simulate a logout process
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    _isLoggedIn = false;
    notifyListeners();
  }
}
