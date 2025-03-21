import 'package:flutter/material.dart';
import 'package:kissima/pages/splash_screen.dart';
import 'package:kissima/providers/auth_provider.dart';
import 'package:kissima/providers/schedule_provider.dart';
import 'package:kissima/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/schedule.dart';
import 'pages/settings.dart';
import 'pages/login.dart';
// Create this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await SharedPreferences.getInstance();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefs: prefs),
        ),
        ChangeNotifierProvider(
          create: (context) => FeedingScheduleProvider(),
        )
      ],
      child: SmartPetFeederApp(),
    ),
  );
}

class SmartPetFeederApp extends StatelessWidget {
  const SmartPetFeederApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Pet Feeder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MySplashScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String title = 'Smart Pet Feeder Dashboard';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to Smart Pet Feeder!'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Update your AppDrawer logout functionality
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(20))),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedule Feedings'),
            onTap: () {
              // Navigate to schedule screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScheduleScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
