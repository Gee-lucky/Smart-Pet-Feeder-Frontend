import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modals/feeding_schedule.dart';
import '../providers/auth_provider.dart';
import '../providers/feeding_schedule_provider.dart';
import '../providers/theme_notifier.dart';
import '../utils/theme/theme.dart'; // For ThemeNotifier

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double _portion = 1.0;
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _portionController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Alignment> _gradientBeginAnimation;
  late Animation<Alignment> _gradientEndAnimation;
  late Animation<double> _glowAnimation;
  int _currentIndex = 1; // Set to 1 for ScheduleScreen

  @override
  void initState() {
    super.initState();
    _portionController.text = _portion.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedingScheduleProvider>(context, listen: false).fetchSchedules();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _gradientBeginAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(_animationController);

    _gradientEndAnimation = Tween<Alignment>(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).animate(_animationController);

    _glowAnimation = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _portionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return; // Prevent navigation if already on the current screen

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/schedule');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
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
    final theme = Theme.of(context);

    return Scaffold(
      // Background color is automatically set by scaffoldBackgroundColor in ThemeData
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Theme Toggle Button (for testing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        theme.brightness == Brightness.dark ? Icons.wb_sunny : Icons.nightlight_round,
                        color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                      ),
                      onPressed: () {
                        Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                      },
                    ),
                  ],
                ),
                // Animated Logo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: _gradientBeginAnimation.value,
                          end: _gradientEndAnimation.value,
                          colors: [
                            Colors.blueAccent,
                            Colors.blue,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: _glowAnimation.value / 4 * 0.2),
                            blurRadius: _glowAnimation.value,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 60,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Feeding Schedule',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your pet’s feeding schedule',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 40),
                // Calendar Container
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppThemeColors.secondaryColor, // White container
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TableCalendar(
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
                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: GoogleFonts.poppins(
                        color: Colors.black87,
                      ),
                      weekendTextStyle: GoogleFonts.poppins(
                        color: Colors.black54,
                      ),
                      todayTextStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      selectedTextStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Input Container
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppThemeColors.secondaryColor, // White container
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portion (cups)',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _portionController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter the portion',
                        ),
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _portion = double.tryParse(value) ?? 1.0;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select Time',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _selectTime(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Time: ${_selectedTime.format(context)}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _scheduleFeeding,
                              child: Text(
                                'Schedule Feeding',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Feed Now',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Schedules List
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppThemeColors.secondaryColor, // White container
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Consumer<FeedingScheduleProvider>(
                    builder: (context, scheduleProvider, child) {
                      if (scheduleProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (scheduleProvider.schedules.isEmpty) {
                        return Center(
                          child: Text(
                            'No schedules found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: scheduleProvider.schedules.length,
                        itemBuilder: (context, index) {
                          final schedule = scheduleProvider.schedules[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.inputDecorationTheme.fillColor, // Match text field background
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              title: Text(
                                'Date: ${schedule.date.toString().split('.')[0]}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                'Portion: ${schedule.portion} cups',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
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
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        color: AppThemeColors.secondaryColor, // White background
        buttonBackgroundColor: theme.primaryColor, // Primary color for active item
        height: 65,
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.transparent,
        items: [
          Icon(
            Icons.home,
            size: 30,
            color: _currentIndex == 0 ? Colors.white : Colors.grey,
          ),
          Icon(
            Icons.schedule,
            size: 30,
            color: _currentIndex == 1 ? Colors.white : Colors.grey,
          ),
          Icon(
            Icons.settings,
            size: 30,
            color: _currentIndex == 2 ? Colors.white : Colors.grey,
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}