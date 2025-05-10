import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feeding_schedule_provider.dart';
import '../../models/feeding_schedule.dart';
import '../../widgets/custom_button.dart';
import '../common/bottom_nav.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _amountController = TextEditingController();
  DateTime? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userId != null) {
      Provider.of<FeedingScheduleProvider>(context, listen: false)
          .fetchSchedules(authProvider.userId!);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _selectedTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final feedingProvider = Provider.of<FeedingScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Feeding Schedules')),
      body: authProvider.userId == null
          ? const Center(child: Text('Please log in to view schedules'))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount (grams)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedTime == null
                            ? 'Select Time'
                            : 'Time: ${_selectedTime!.hour}:${_selectedTime!.minute}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: const Text('Pick Time'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                  text: 'Add Schedule',
                  onPressed: () async {
                    if (_selectedTime == null ||
                        _amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    setState(() => _isLoading = true);
                    try {
                      final schedule = FeedingSchedule(
                        id: DateTime.now().toString(),
                        time: _selectedTime!,
                        amount: double.parse(_amountController.text),
                      );
                      await feedingProvider.addSchedule(
                          authProvider.userId!, schedule);
                      _amountController.clear();
                      setState(() => _selectedTime = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Schedule added')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                    setState(() => _isLoading = false);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: feedingProvider.schedules.isEmpty
                ? const Center(child: Text('No schedules found'))
                : ListView.builder(
              itemCount: feedingProvider.schedules.length,
              itemBuilder: (context, index) {
                final schedule = feedingProvider.schedules[index];
                return ListTile(
                  title: Text(
                      'Time: ${schedule.time.hour}:${schedule.time.minute}'),
                  subtitle: Text('Amount: ${schedule.amount}g'),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}