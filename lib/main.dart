import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/feeding_schedule_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // const MyApp(),
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
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
        locale: DevicePreview.locale(context), // Support DevicePreview locale
        builder: DevicePreview.appBuilder, // Apply DevicePreview transformations
        title: 'Smart Pet Feeder',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}