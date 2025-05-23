// import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/feeding_schedule_provider.dart';

// Initialize the notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  tz.initializeTimeZones(); // Initialize timezone data here

  // Request permissions for Android 13+
  if (defaultTargetPlatform == TargetPlatform.android) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notifications
  initializeNotifications();
  runApp(
    const MyApp(),
    // DevicePreview(
    //   enabled: !kReleaseMode, // Enable only in debug mode
    //   builder: (context) => const MyApp(),
    // ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedingScheduleProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // locale: DevicePreview.locale(context), // Support DevicePreview locale
        // builder: DevicePreview.appBuilder, // Apply DevicePreview transformations
        title: 'Smart Pet Feeder',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}