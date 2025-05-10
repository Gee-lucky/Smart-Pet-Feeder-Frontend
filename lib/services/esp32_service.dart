import 'dart:convert';
import 'package:http/http.dart' as http;

class Esp32Service {
  static const String _baseUrl = 'http://192.168.1.54';

  Future<void> triggerFeeding() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/feed'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to trigger feeding');
      }
    } catch (e) {
      throw Exception('Error communicating with ESP32: $e');
    }
  }

  Future<String> getDeviceStatus() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/status'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] ?? 'Unknown';
      } else {
        throw Exception('Failed to get device status');
      }
    } catch (e) {
      throw Exception('Error communicating with ESP32: $e');
    }
  }
}