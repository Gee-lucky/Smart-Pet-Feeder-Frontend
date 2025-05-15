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

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  DateTime? _selectedTime;
  bool _isLoading = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Trigger fade-in animation
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _isVisible = true);
    });
    // Fetch schedules asynchronously
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userId != null) {
      try {
        await Provider.of<FeedingScheduleProvider>(context, listen: false)
            .fetchSchedules(authProvider.userId!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching schedules: $e')),
        );
      }
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
      appBar: AppBar(
        title: const Text('Feeding Schedules'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade50,
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        size: 40,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Feeding Schedules',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (authProvider.userId == null)
                      Text(
                        'Please log in to view schedules',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Column(
                        children: [
                          TextField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount (grams)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedTime == null
                                      ? 'Select Time'
                                      : 'Time: ${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _selectTime(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
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
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          feedingProvider.schedules.isEmpty
                              ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'No schedules found',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: feedingProvider.schedules.length,
                            itemBuilder: (context, index) {
                              final schedule = feedingProvider.schedules[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    'Time: ${schedule.time.hour}:${schedule.time.minute.toString().padLeft(2, '0')}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    'Amount: ${schedule.amount}g',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}