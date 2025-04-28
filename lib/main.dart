import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kissima/pages/forgot_password.dart';
import 'package:kissima/pages/password_reset.dart';
import 'package:kissima/providers/feeding_schedule_provider.dart';
import 'package:kissima/providers/theme_notifier.dart';
import 'package:kissima/utils/theme/theme.dart';
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

  final bool isDarkMode = prefs.getBool("themeMode") ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs: prefs)),
        ChangeNotifierProvider(create: (_) => FeedingScheduleProvider()),
      ],
      child: SmartPetFeederApp(isDarkMode: isDarkMode),
    ),
  );
}

class SmartPetFeederApp extends StatelessWidget {

  final bool isDarkMode;
  const SmartPetFeederApp({super.key , required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier(isDarkMode))
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Pet Feeder',
            locale: settingsProvider.locale,
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('sw', ''), // Swahili
            ],
            localizationsDelegates: [
              // AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            theme: AppThemeColor.lightTheme,
            themeMode: ThemeMode.light,
            darkTheme: AppThemeColor.darkTheme,
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
      ),
    );
  }
}



