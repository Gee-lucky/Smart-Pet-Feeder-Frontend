import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences prefs;
  late ThemeMode _themeMode = ThemeMode.light;
  late Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void changeLanguage(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  SettingsProvider({required this.prefs}) {
    // Load saved settings
    _notificationsEnabled = prefs.getBool('notifications') ?? true;
    _alertSensitivity = prefs.getDouble('sensitivity') ?? 0.5;
  }

  bool _notificationsEnabled = true;
  double _alertSensitivity = 0.5;

  bool get notificationsEnabled => _notificationsEnabled;
  double get alertSensitivity => _alertSensitivity;

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await prefs.setBool('notifications', value);
    notifyListeners();
  }

  Future<void> setSensitivity(double value) async {
    _alertSensitivity = value;
    await prefs.setDouble('sensitivity', value);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode, '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    notifyListeners();
  }
}
