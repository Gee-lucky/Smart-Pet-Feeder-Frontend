import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kissima/services/app_urls.dart';
import 'package:kissima/modals/user_preference.dart';

class AuthRequests {
  static Future<http.Response> login(Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.login);
    print('Login URL: $url');
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> register(Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.register);
    print('Register URL: $url');
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> resetPassword(Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.resetPassword);
    print('Reset Password URL: $url');
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> resetPasswordEmail(Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.resetPasswordEmail);
    print('Reset Password Email URL: $url');
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> logout(String refreshToken) async {
    final url = Uri.parse(AppUrl.logout);
    print('Logout URL: $url');
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"refresh": refreshToken}),
    ).timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> feed(Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.feed);
    final token = await UserPreferences.getAccessToken();
    print('Feed URL: $url');
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> getProfile() async {
    final url = Uri.parse(AppUrl.profile);
    final token = await UserPreferences.getAccessToken();
    print('Profile URL: $url');
    return await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> updateProfile(Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.profile);
    final token = await UserPreferences.getAccessToken();
    print('Update Profile URL: $url');
    return await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> refreshToken(String refreshToken) async {
    final url = Uri.parse(AppUrl.tokenRefresh);
    print('Token Refresh URL: $url');
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"refresh": refreshToken}),
    ).timeout(const Duration(seconds: 30));
  }
}