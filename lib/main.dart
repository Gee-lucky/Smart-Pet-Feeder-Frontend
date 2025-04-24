import 'package:flutter/material.dart';
import 'package:kissima/pages/forgot_password.dart';
import 'package:kissima/pages/password_reset.dart';
import 'package:kissima/providers/feeding_schedule_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kissima/pages/splash_screen.dart';
import 'package:kissima/pages/login.dart';
import 'package:kissima/pages/register.dart';
import 'package:kissima/pages/schedule.dart';
import 'package:kissima/pages/settings.dart';
import 'package:kissima/pages/home.dart';
import 'package:kissima/providers/auth_provider.dart';
import 'package:kissima/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs: prefs)),
        ChangeNotifierProvider(create: (_) => FeedingScheduleProvider()),
      ],
      child: const SmartPetFeederApp(),
    ),
  );
}

class SmartPetFeederApp extends StatelessWidget {
  const SmartPetFeederApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Pet Feeder',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
          ),
          themeMode: settingsProvider.themeMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/schedule': (context) => const ScheduleScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/password-reset': (context) => const PasswordResetScreen(),
          },
        );
      },
    );
  }
}