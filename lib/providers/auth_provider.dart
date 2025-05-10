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

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  int? get userId => _userId;

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
        _userId = Jwt.parseJwt(_accessToken!)['user_id']; // Extract user_id from token
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}