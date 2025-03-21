import 'package:flutter/material.dart';

import '../pages/schedule.dart';

class FeedingScheduleProvider extends ChangeNotifier {
  final List<FeedingScheduleEntry> _scheduleEntries = [];

  List<FeedingScheduleEntry> get scheduleEntries => _scheduleEntries;

  FeedingScheduleProvider() {
    // Initialize with sample data
    _scheduleEntries.addAll([
      FeedingScheduleEntry(
        time: DateTime.now().add(const Duration(hours: 1)),
        portion: 0.5,
        daysOfWeek: [true, true, true, true, true, true, true],
        label: 'Morning Feeding',
      ),
      FeedingScheduleEntry(
        time: DateTime.now().add(const Duration(hours: 5)),
        portion: 0.75,
        daysOfWeek: [true, true, true, true, true, true, true],
        label: 'Evening Feeding',
      ),
    ]);
  }

  void addEntry(FeedingScheduleEntry entry) {
    _scheduleEntries.add(entry);
    notifyListeners();
  }

  void toggleEntryEnabled(int index) {
    _scheduleEntries[index].isEnabled = !_scheduleEntries[index].isEnabled;
    notifyListeners();
  }

  void deleteEntry(int index) {
    _scheduleEntries.removeAt(index);
    notifyListeners();
  }
}
