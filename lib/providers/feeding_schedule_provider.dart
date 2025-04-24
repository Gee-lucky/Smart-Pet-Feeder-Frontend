import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modals/feeding_schedule.dart';

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
      _schedules = schedulesList
          .map((json) => FeedingSchedule.fromJson(json))
          .toList();
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

  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = jsonEncode(_schedules.map((s) => s.toJson()).toList());
    await prefs.setString('schedules', schedulesJson);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}