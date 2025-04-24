import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_modal.dart';

class UserPreferences {
  static const String _userKey = 'user';
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  static Future<void> setUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));
    }
    return null;
  }

  static Future<void> setTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}