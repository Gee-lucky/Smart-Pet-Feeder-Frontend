import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_urls.dart';

class AuthRequests {

  static const String baseUrl = 'http://localhost:8000/api/v1/auth';
  static Future<http.Response> login(Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.login);
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Login request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> register(Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.register);
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Register request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> forgotPassword(Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.forgotPassword);
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Forgot password request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> resetPassword(Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.resetPassword);
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Reset password request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> logout(String refreshToken) async {
    final url = Uri.parse(AppUrl.logout);
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"refresh": refreshToken}),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Logout request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> updateProfile(
      String accessToken, Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.profile);
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Update profile request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> getProfile(String accessToken) async {
    final url = Uri.parse(AppUrl.profile);
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Get profile request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> feed(
      String accessToken, Map<String, dynamic> data) async {
    final url = Uri.parse(AppUrl.feed);
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Feed request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> refreshToken(String refreshToken) async {
    final url = Uri.parse(AppUrl.refreshToken);
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Refresh token request failed: $e');
      rethrow;
    }
  }
}