import 'dart:convert';
import 'package:http/http.dart' as http;

class Esp32Service {
  static const String _baseUrl = 'http://192.168.1.154';
  // static const String _baseUrl= 'http://192.168.23.200';

  Future<void> triggerFeeding() async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/feed'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Request timed out after 5 seconds');
      });
      if (response.statusCode != 200) {
        print('Trigger feeding failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to trigger feeding: ${response.statusCode} - ${response.reasonPhrase}');
      }
      print('Trigger feeding successful: ${response.body}');
    } catch (e) {
      print('Trigger feeding error: $e');
      rethrow; // Rethrow to allow HomeScreen to catch and display the error
    }
  }

  Future<String> getDeviceStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/status'))
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Request timed out after 5 seconds');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] ?? 'Unknown';
        print('Device status fetched: $status');
        return status;
      } else {
        print('Get device status failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get device status: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Get device status error: $e');
      rethrow; // Rethrow to allow HomeScreen to catch and display the error
    }
  }
}