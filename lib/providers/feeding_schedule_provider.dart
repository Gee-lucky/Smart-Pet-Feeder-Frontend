import 'package:flutter/material.dart';
import '../models/feeding_schedule.dart';
import '../services/api_service.dart';

class FeedingScheduleProvider with ChangeNotifier {
  List<FeedingSchedule> _schedules = [];

  List<FeedingSchedule> get schedules => _schedules;

  Future<void> fetchSchedules(int userId) async {
    try {
      final response = await ApiService().getSchedules(userId);
      _schedules = (response)
          .map((json) => FeedingSchedule.fromJson(json))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching schedules: $e');
      throw e; // Propagate error for UI handling
    }
  }

  Future<void> addSchedule(int userId, FeedingSchedule schedule) async {
    try {
      await ApiService().addSchedule(userId, schedule.time, schedule.amount);
      await fetchSchedules(userId);
    } catch (e) {
      print('Error adding schedule: $e');
      throw e; // Propagate error
    }
  }

  Future<void> logFeeding(int userId, DateTime time) async {
    try {
      await ApiService().logFeeding(userId, time);
    } catch (e) {
      print('Error logging feeding: $e');
      throw e; // Propagate error
    }
  }
}