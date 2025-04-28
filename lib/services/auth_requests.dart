import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRequests {
  static const String baseUrl = '192.168.1.131:8000';
  static Future<http.Response> login(Map<String, dynamic> data) async {
    try {
      final url = Uri.http(baseUrl, 'api/v1/auth/login/');
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Login request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> register(Map<String, dynamic> data) async {
    try {
      final url = Uri.http(baseUrl, 'api/v1/auth/register/');
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Register request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> forgotPassword(Map<String, dynamic> data) async {
    try {
      final url = Uri.http(baseUrl, 'api/v1/auth/forgot-password/');
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Forgot password request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> resetPassword(Map<String, dynamic> data) async {
    try {
      final url = Uri.http(baseUrl, 'api/v1/auth/reset-password/');
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Reset password request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> logout(String refreshToken) async {
       try {
      final url = Uri.http(baseUrl, 'api/v1/auth/logout/');
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"refresh": refreshToken}),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Logout request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> updateProfile(
      String accessToken, Map<String, dynamic> data) async {
    try {
      final url = Uri.http(baseUrl, 'api/v1/auth/profile/');
      final response = await http
          .put(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $accessToken",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Update profile request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> getProfile(String accessToken) async {
    try {
      final url = Uri.http(baseUrl, 'api/v1/auth/profile/');
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
    try {
      final url = Uri.http(baseUrl, 'api/v1/auth/feed/');
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $accessToken",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Feed request failed: $e');
      rethrow;
    }
  }

  static Future<http.Response> refreshToken(String refreshToken) async {
    try {
      final url = Uri.http(baseUrl, 'api/v1/auth/refresh/');
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      print('Refresh token request failed: $e');
      rethrow;
    }
  }
}
