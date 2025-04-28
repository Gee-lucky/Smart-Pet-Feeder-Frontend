import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modals/feeding_schedule.dart';
import '../modals/user_preference.dart';
import 'auth_provider.dart';

class FeedingScheduleProvider with ChangeNotifier {
  List<FeedingSchedule> _schedules = [];
  bool _isLoading = false;

  List<FeedingSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;

  Future<void> fetchSchedules() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getString('schedules') ?? '[]';
      final List<dynamic> schedulesList = jsonDecode(schedulesJson);
      _schedules =
          schedulesList.map((json) => FeedingSchedule.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Failed to fetch schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> addSchedule(FeedingSchedule schedule) async {
    _setLoading(true);
    try {
      final newSchedule = FeedingSchedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: schedule.date,
        portion: schedule.portion,
      );
      _schedules.add(newSchedule);
      await _saveSchedules();
      notifyListeners();
      return {'status': true, 'message': 'Schedule added successfully'};
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to add schedule: $e',
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> deleteSchedule(String id) async {
    _setLoading(true);
    try {
      _schedules.removeWhere((schedule) => schedule.id == id);
      await _saveSchedules();
      notifyListeners();
      return {'status': true, 'message': 'Schedule deleted successfully'};
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to delete schedule: $e',
      };
    } finally {
      _setLoading(false);
    }
  }

  static const String baseUrl = '192.168.1.131:8000';
  Future<Map<String, dynamic>> scheduleFeeding(
      DateTime dateTime, double portion) async {
    try {
      final url = Uri.http(baseUrl, 'api/v1/auth/schedule-feeding/');
      final response = await http
          .post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'dateTime': dateTime.toIso8601String(),
          'portion': portion,
        }),
      );

      if (response.statusCode == 200) {
        notifyListeners();
        return {'message': 'Feeding scheduled successfully'};
      } else {
        return {'message': 'Failed to schedule feeding'};
      }
    } catch (e) {
      return {'message': 'Error: $e'};
    }
  }
  Future<Map<String, dynamic>> feedNow(BuildContext context) async {
    try {
      final user = await UserPreferences.getUser();
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final baseUrl = '192.168.1.131:8000'; // Updated baseUrl as per your code
      final url = Uri.http(baseUrl, '/api/v1/feeding/feed-now/');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({'portion': 1}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Feeding triggered successfully'};
      } else if (response.statusCode == 401) {
        // Attempt to refresh the token
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final refreshResult = await authProvider.refreshToken!;
        if (refreshResult==true) {
          // Retry the request with the new token
          final updatedUser = await UserPreferences.getUser();
          if (updatedUser == null) {
            return {'success': false, 'message': 'User not found after token refresh'};
          }
          final retryResponse = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${updatedUser.token}',
            },
            body: jsonEncode({'portion': 1}),
          );
          if (retryResponse.statusCode == 200) {
            return {'success': true, 'message': 'Feeding triggered successfully'};
          } else {
            return {
              'success': false,
              'message': 'Failed to trigger feeding after token refresh: ${retryResponse.statusCode}',
            };
          }
        } else {
          // Token refresh failed, log the user out
          await UserPreferences.clearUser();
          Navigator.pushReplacementNamed(context, '/login'); // Removed context.mounted check
          return {'success': false, 'message': 'Session expired. Please log in again'};
        }
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Endpoint not found: Please check the server configuration'};
      } else {
        return {
          'success': false,
          'message': 'Failed to trigger feeding: ${response.statusCode} ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }


  // Future<Map<String, dynamic>> feedNow(BuildContext context) async {
  //   try {
  //     final user = await UserPreferences.getUser();
  //     if (user == null) {
  //       return {'success': false, 'message': 'User not authenticated'};
  //     }
  //
  //     final baseUrl = '192.168.1.131:8000';
  //     final url = Uri.http(baseUrl, '/api/v1/feeding/feed-now/');
  //
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ${user.token}',
  //       },
  //       body: jsonEncode({'portion': 1}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return {'success': true, 'message': 'Feeding triggered successfully'};
  //     } else if (response.statusCode == 401) {
  //       // Attempt to refresh the token
  //       final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //       final refreshResult = await authProvider.refreshToken();
  //       if (refreshResult['success']) {
  //         // Retry the request with the new token
  //         final updatedUser = await UserPreferences.getUser();
  //         if (updatedUser == null) {
  //           return {'success': false, 'message': 'User not found after token refresh'};
  //         }
  //         final retryResponse = await http.post(
  //           url,
  //           headers: {
  //             'Content-Type': 'application/json',
  //             'Authorization': 'Bearer ${updatedUser.token}',
  //           },
  //           body: jsonEncode({'portion': 1}),
  //         );
  //         if (retryResponse.statusCode == 200) {
  //           return {'success': true, 'message': 'Feeding triggered successfully'};
  //         } else {
  //           return {
  //             'success': false,
  //             'message': 'Failed to trigger feeding after token refresh: ${retryResponse.statusCode}',
  //           };
  //         }
  //       } else {
  //         // Token refresh failed, log the user out
  //         await UserPreferences.clearUser();
  //         if (context.mounted) {
  //           Navigator.pushReplacementNamed(context, '/login');
  //         }
  //         return {'success': false, 'message': 'Session expired. Please log in again'};
  //       }
  //
  //     } else if (response.statusCode == 404) {
  //       return {'success': false, 'message': 'Endpoint not found: Please check the server configuration'};
  //     } else {
  //       return {
  //         'success': false,
  //         'message': 'Failed to trigger feeding: ${response.statusCode} ${response.reasonPhrase}',
  //       };
  //     }
  //   } catch (e) {
  //     return {'success': false, 'message': 'Error: $e'};
  //   }
  // }



  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson =
        jsonEncode(_schedules.map((s) => s.toJson()).toList());
    await prefs.setString('schedules', schedulesJson);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
