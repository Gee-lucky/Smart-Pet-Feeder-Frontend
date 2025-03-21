import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/schedule_provider.dart'; // For time formatting

// Data Model: Feeding Schedule Entry
class FeedingScheduleEntry {
  DateTime time;
  double portion; // Customizable portion size (e.g., in cups or grams)
  List<bool> daysOfWeek; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun] (for recurring)
  bool isEnabled; // To pause/resume this specific entry
  String label; // a custom label to identify this entry

  FeedingScheduleEntry({
    required this.time,
    required this.portion,
    required this.daysOfWeek,
    this.isEnabled = true,
    required this.label,
  });

  String getFormattedTime() {
    return DateFormat.jm().format(time); // Format as 1:00 PM
  }
}

// Widget for Displaying a Single Schedule Entry
class ScheduleEntryWidget extends StatelessWidget {
  final FeedingScheduleEntry entry;
  final VoidCallback onToggleEnabled;
  final VoidCallback onDelete;

  const ScheduleEntryWidget({
    super.key,
    required this.entry,
    required this.onToggleEnabled,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 10,
      child: ListTile(
        leading: IconButton(
          icon: entry.isEnabled
              ? const Icon(Icons.pause_circle)
              : const Icon(Icons.play_circle),
          onPressed: onToggleEnabled,
          color: entry.isEnabled ? Colors.orange : Colors.green,
        ),
        title: Text('Time: ${entry.getFormattedTime()}'),
        subtitle: Text('Portion: ${entry.portion}, Label: ${entry.label}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<FeedingScheduleEntry> scheduleEntries = [];

  @override
  void initState() {
    super.initState();
    // Initialize with some sample schedule entries
    scheduleEntries.addAll([
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Schedule Feedings',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Title
//             const Text(
//               'Your Feeding Schedule',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Schedule List
//             Expanded(
//               child: ListView.builder(
//                 itemCount: scheduleEntries.length,
//                 itemBuilder: (context, index) {
//                   return ScheduleEntryWidget(
//                     entry: scheduleEntries[index],
//                     onToggleEnabled: () => _toggleScheduleEntryEnabled(index),
//                     onDelete: () => _deleteScheduleEntry(index),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Implement "Feed Now" logic here
//                   },
//                   icon: const Icon(Icons.fastfood, color: Colors.white),
//                   label: const Text('Feed Now', style: TextStyle(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _addScheduleEntry,
//                   icon: const Icon(Icons.add, color: Colors.white),
//                   label: const Text('Add Feeding', style: TextStyle(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule Feedings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Your Feeding Schedule',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<FeedingScheduleProvider>(
                builder: (context, provider, child) {
                  return ListView.builder(
                    itemCount: provider.scheduleEntries.length,
                    itemBuilder: (context, index) {
                      final entry = provider.scheduleEntries[index];
                      return ScheduleEntryWidget(
                        entry: entry,
                        onToggleEnabled: () =>
                            provider.toggleEntryEnabled(index),
                        onDelete: () => provider.deleteEntry(index),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Consumer<FeedingScheduleProvider>(
              builder: (context, provider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.fastfood, color: Colors.white),
                      label: const Text('Feed Now',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => provider.addEntry(
                        FeedingScheduleEntry(
                          time: DateTime.now(),
                          portion: 0.25,
                          daysOfWeek: [
                            true,
                            true,
                            true,
                            true,
                            true,
                            true,
                            true
                          ],
                          label: 'New Entry',
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add Feeding',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
