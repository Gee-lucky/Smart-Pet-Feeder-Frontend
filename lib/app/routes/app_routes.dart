import 'package:flutter/material.dart';
import '../../ screens/auth/login_screen.dart';
import '../../ screens/auth/register_screen.dart';
import '../../ screens/dashboard/feeding_history_screen.dart';
import '../../ screens/dashboard/home_screen.dart';
import '../../ screens/dashboard/profile_screen.dart';
import '../../ screens/dashboard/schedule_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String schedule = '/schedule';
  static const String feedingHistory = '/feeding_history';
  static const String profile = '/profile';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    schedule: (context) => const ScheduleScreen(),
    feedingHistory: (context) => const FeedingHistoryScreen(),
    profile: (context) => const ProfileScreen(),
  };
}