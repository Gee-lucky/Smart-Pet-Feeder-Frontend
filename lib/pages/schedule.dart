import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../modals/feeding_schedule.dart';
import '../providers/auth_provider.dart';
import '../providers/feeding_schedule_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double _portion = 1.0;
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _portionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _portionController.text = _portion.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedingScheduleProvider>(context, listen: false).fetchSchedules();
    });
  }

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleFeeding() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    final scheduleProvider = Provider.of<FeedingScheduleProvider>(context, listen: false);
    final dateTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final schedule = FeedingSchedule(
      id: '',
      date: dateTime,
      portion: _portion,
    );

    final result = await scheduleProvider.addSchedule(schedule);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      if (result['status']) {
        scheduleProvider.fetchSchedules();
      }
    }
  }

  Future<void> _feedNow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.feed({'portion': _portion});

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
        title: const Text('Feeding Schedule', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _portionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Portion (cups)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _portion = double.tryParse(value) ?? 1.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text(
                    'Time: ${_selectedTime.format(context)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _scheduleFeeding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Schedule Feeding',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _feedNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Feed Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<FeedingScheduleProvider>(
              builder: (context, scheduleProvider, child) {
                if (scheduleProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (scheduleProvider.schedules.isEmpty) {
                  return const Center(child: Text('No schedules found'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: scheduleProvider.schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = scheduleProvider.schedules[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          'Date: ${schedule.date.toString().split('.')[0]}',
                        ),
                        subtitle: Text('Portion: ${schedule.portion} cups'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final result = await scheduleProvider.deleteSchedule(schedule.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['message'])),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
