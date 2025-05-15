import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/feeding_schedule.dart';
import '../services/api_service.dart';

// Import the initialized plugin from main.dart
import '../main.dart' as main;

class FeedingScheduleProvider with ChangeNotifier {
  List<FeedingSchedule> _schedules = [];

  List<FeedingSchedule> get schedules => _schedules;

  // Initialize timezone data
  FeedingScheduleProvider() {
    tz.initializeTimeZones();
  }

  // Helper method to schedule a notification
  Future<void> _scheduleNotification(FeedingSchedule schedule) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'feeding_channel_id',
      'Feeding Reminders',
      channelDescription: 'Notifications for scheduled pet feedings',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    // Convert schedule.time to a timezone-aware date
    final scheduledDate = tz.TZDateTime.from(schedule.time, tz.local);

    await main.flutterLocalNotificationsPlugin.zonedSchedule(
      schedule.id.hashCode, // Unique ID for the notification
      'Feeding Time!',
      'It\'s time to feed your pet: ${schedule.amount}g at ${schedule.time.hour}:${schedule.time.minute.toString().padLeft(2, '0')}',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Optional: repeat daily
    );
  }

  Future<void> fetchSchedules(int userId) async {
    try {
      final response = await ApiService().getSchedules(userId);
      _schedules = (response)
          .map((json) => FeedingSchedule.fromJson(json))
          .toList();
      // Schedule notifications for all fetched schedules
      for (var schedule in _schedules) {
        if (schedule.time.isAfter(DateTime.now())) {
          await _scheduleNotification(schedule);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching schedules: $e');
      throw e;
    }
  }

  Future<void> addSchedule(int userId, FeedingSchedule schedule) async {
    try {
      await ApiService().addSchedule(userId, schedule.time, schedule.amount);
      // Schedule a notification for the new schedule if it's in the future
      if (schedule.time.isAfter(DateTime.now())) {
        await _scheduleNotification(schedule);
      }
      await fetchSchedules(userId);
    } catch (e) {
      print('Error adding schedule: $e');
      throw e;
    }
  }

  Future<void> logFeeding(int userId, DateTime time) async {
    try {
      await ApiService().logFeeding(userId, time);
    } catch (e) {
      print('Error logging feeding: $e');
      throw e;
    }
  }
}