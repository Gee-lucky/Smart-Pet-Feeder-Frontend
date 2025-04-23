import 'package:shared_preferences/shared_preferences.dart';
import 'user_modal.dart';

class UserPreferences {
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('access_token', user.accessToken);
    await prefs.setString('first_name', user.firstName ?? '');
    await prefs.setString('last_name', user.lastName ?? '');
    await prefs.setString('phone_number', user.phone ?? '');
    await prefs.setString('refresh_token', user.refreshToken ?? '');
    await prefs.setString('user_type', user.userType ?? '');
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) return null;

    return User(
      id: userId,
      username: prefs.getString('username') ?? '',
      email: prefs.getString('email'),
      accessToken: prefs.getString('access_token') ?? '',
      firstName: prefs.getString('first_name'),
      lastName: prefs.getString('last_name'),
      phone: prefs.getString('phone_number'),
      refreshToken: prefs.getString('refresh_token'),
      userType: prefs.getString('user_type'),
    );
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('access_token');
    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('phone_number');
    await prefs.remove('refresh_token');
    await prefs.remove('user_type');
  }
}