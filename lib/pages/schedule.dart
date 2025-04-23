import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/auth_provider.dart';

class FeedingScheduleEntry {
  DateTime time;
  double portion;
  List<bool> daysOfWeek;
  bool isEnabled;
  String label;

  FeedingScheduleEntry({
    required this.time,
    required this.portion,
    required this.daysOfWeek,
    this.isEnabled = true,
    required this.label,
  });

  String getFormattedTime() {
    return DateFormat.jm().format(time);
  }

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'portion': portion,
    'daysOfWeek': daysOfWeek,
    'isEnabled': isEnabled,
    'label': label,
  };

  factory FeedingScheduleEntry.fromJson(Map<String, dynamic> json) =>
      FeedingScheduleEntry(
        time: DateTime.parse(json['time']),
        portion: json['portion'],
        daysOfWeek: List<bool>.from(json['daysOfWeek']),
        isEnabled: json['isEnabled'],
        label: json['label'],
      );
}

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
        subtitle: Text('Portion: ${entry.portion} cups, Label: ${entry.label}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class ScheduleTimeline extends StatelessWidget {
  final List<FeedingScheduleEntry> entries;

  const ScheduleTimeline({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = entries..sort((a, b) => a.time.compareTo(b.time));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        return TimelineTile(
          time: entry.getFormattedTime(),
          title: entry.label,
          subtitle: '${entry.portion} cups',
          isEnabled: entry.isEnabled,
        );
      },
    );
  }
}

class TimelineTile extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final bool isEnabled;

  const TimelineTile({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isEnabled ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: isEnabled ? Colors.black54 : Colors.grey,
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ],
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Future<void> _showAddFeedingDialog(BuildContext context) async {
    final provider = Provider.of<FeedingScheduleProvider>(context, listen: false);
    final timeController = TextEditingController(
        text: DateFormat.Hm().format(DateTime.now()));
    final portionController = TextEditingController(text: '0.25');
    final labelController = TextEditingController(text: 'New Feeding');
    final daysOfWeek = List<bool>.filled(7, true);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Feeding Schedule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time (HH:mm)'),
                readOnly: true,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    timeController.text = time.format(context);
                  }
                },
              ),
              TextField(
                controller: portionController,
                decoration: const InputDecoration(labelText: 'Portion (cups)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final time = DateFormat.Hm().parse(timeController.text);
              provider.addEntry(
                FeedingScheduleEntry(
                  time: DateTime.now().copyWith(
                    hour: time.hour,
                    minute: time.minute,
                  ),
                  portion: double.parse(portionController.text),
                  daysOfWeek: daysOfWeek,
                  label: labelController.text,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFeedNow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.feed(0.25); // Default portion
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

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
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ScheduleTimeline(entries: provider.scheduleEntries),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                        ),
                      ],
                    ),
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
                      onPressed: _handleFeedNow,
                      icon: const Icon(Icons.fastfood, color: Colors.white),
                      label: const Text('Feed Now',
                          style: TextStyle(color: Colors.white)),
                      style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddFeedingDialog(context),
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