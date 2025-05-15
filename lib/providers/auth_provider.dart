import 'package:flutter/foundation.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _accessToken;
  int? _userId;
  String? _email; // Added email property

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  int? get userId => _userId;
  String? get email => _email; // Getter for email

  Future<bool> register(String email, String password, String firstName, String lastName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(email, password, firstName, lastName);
      if (response['statusCode'] == 200) {
        final data = response['body'];
        _accessToken = data['access'];
        _userId = Jwt.parseJwt(_accessToken!)['user_id'];
        _email = email; // Store the input email (or from data if API provides it)
        await _apiService.saveTokens(data['access'], data['refresh']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration failed: ${response['body']['detail'] ?? response['body'].toString()}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      if (response['statusCode'] == 200) {
        final data = response['body'];
        _accessToken = data['access'];
        _userId = Jwt.parseJwt(_accessToken!)['user_id'];
        _email = email; // Store the input email (or from data if API provides it)
        await _apiService.saveTokens(data['access'], data['refresh']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login failed: ${response['body'].toString()}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _userId = null;
    _accessToken = null;
    _email = null; // Clear email on sign out
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}