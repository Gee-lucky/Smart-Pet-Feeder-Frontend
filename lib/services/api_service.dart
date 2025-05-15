import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.131:8000/api';
  // static const String baseUrl = 'http://192.168.23.58:8000/api';
  static const String registerUrl = '$baseUrl/register/';
  static const String loginUrl = '$baseUrl/login/';
  static const String feedingsUrl = '$baseUrl/feedings/';
  static const String schedulesUrl = '$baseUrl/schedules/';
  static const String logFeedingUrl = '$baseUrl/feedings/create/';

  Future<Map<String, dynamic>> register(String email, String password, String firstName, String lastName) async {
    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );
      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');
      if (response.statusCode == 200) {
        return {
          'statusCode': response.statusCode,
          'body': jsonDecode(response.body),
        };
      } else {
        throw Exception('Registration failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Register Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getFeedings(int userId) async {
    try {
      final tokens = await getTokens();
      final response = await http.get(
        Uri.parse('$feedingsUrl?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokens['access_token']}',
        },
      );
      print('Get Feedings Response Status: ${response.statusCode}');
      print('Get Feedings Response Body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load feedings: ${response.body}');
      }
    } catch (e) {
      print('Get Feedings Error: $e');
      rethrow;
    }
  }


  Future<List<dynamic>> getSchedules(int userId) async {
    try {
      final tokens = await getTokens();
      final response = await http.get(
        Uri.parse('$schedulesUrl?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokens['access_token']}',
        },
      );
      print('Get Schedules Response Status: ${response.statusCode}');
      print('Get Schedules Response Body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load schedules: ${response.body}');
      }
    } catch (e) {
      print('Get Schedules Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addSchedule(int userId, DateTime time, double amount) async {
    try {
      final tokens = await getTokens();
      final response = await http.post(
        Uri.parse(schedulesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokens['access_token']}',
        },
        body: jsonEncode({
          'user_id': userId,
          'time': time.toIso8601String(),
          'amount': amount,
        }),
      );
      print('Add Schedule Response Status: ${response.statusCode}');
      print('Add Schedule Response Body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      print('Add Schedule Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> logFeeding(int userId, DateTime time) async {
    try {
      final tokens = await getTokens();
      final response = await http.post(
        Uri.parse(logFeedingUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${tokens['access_token']}',
        },
        body: jsonEncode({
          'user_id': userId,
          'time': time.toIso8601String(),
        }),
      );
      print('Log Feeding Response Status: ${response.statusCode}');
      print('Log Feeding Response Body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      print('Log Feeding Error: $e');
      rethrow;
    }
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'access_token': prefs.getString('access_token'),
      'refresh_token': prefs.getString('refresh_token'),
    };
  }
}



