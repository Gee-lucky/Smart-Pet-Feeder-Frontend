import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kissima/services/auth_requests.dart';
import '../modals/user_modal.dart';
import '../modals/user_preference.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = false;

  User? get user => _user;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> login(String username, String password) async {
    _setLoading(true);
    try {
      final Map<String, dynamic> logInData = {
        'username': username,
        'password': password,
      };
      final response = await AuthRequests.login(logInData);
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        _user = User.fromJson(responseData['user']);
        _accessToken = responseData['tokens']['access'];
        _refreshToken = responseData['tokens']['refresh'];
        await UserPreferences.setUser(_user!);
        await UserPreferences.setTokens(_accessToken!, _refreshToken!);
        notifyListeners();
        return {'status': true, 'message': responseData['message']};
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to connect to the server: $e'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      final response = await AuthRequests.register(userData);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        return {'status': true, 'message': responseData['message']};
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to connect to the server: $e'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _setLoading(true);
    try {
      final response = await AuthRequests.forgotPassword({'email': email});
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'status': true, 'message': responseData['detail']};
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Failed to send reset email'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to connect to the server: $e'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      String token, String newPassword) async {
    _setLoading(true);
    try {
      final response = await AuthRequests.resetPassword({
        'Token': token,
        'new_password': newPassword,
      });
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'status': true, 'message': responseData['message']};
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Failed to reset password'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to connect to the server: $e'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> logout() async {
    _setLoading(true);
    try {
      if (_refreshToken == null) {
        return {'status': false, 'message': 'No refresh token available'};
      }
      final response = await AuthRequests.logout(_refreshToken!);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await UserPreferences.clearUser();
        _user = null;
        _accessToken = null;
        _refreshToken = null;
        notifyListeners();
        return {'status': true, 'message': responseData['message']};
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Logout failed'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to connect to the server: $e'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> feed(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (_accessToken == null) {
        return {'status': false, 'message': 'No access token available'};
      }
      final response = await AuthRequests.feed(_accessToken!, data);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'status': true, 'message': responseData['message']};
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Failed to trigger feeding'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to connect to the server: $e'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    _setLoading(true);
    try {
      if (_accessToken == null) {
        return {'status': false, 'message': 'No access token available'};
      }
      final response = await AuthRequests.updateProfile(
        _accessToken!,
        profileData,
      );
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _user = User.fromJson(responseData['data']);
        await UserPreferences.setUser(_user!);
        notifyListeners();
        return {'status': true, 'message': responseData['message']};
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Failed to update profile'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to connect to the server: $e'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> refreshAuthToken() async {
    if (_refreshToken == null) {
      return {'status': false, 'message': 'No refresh token available'};
    }

    try {
      final response = await AuthRequests.refreshToken(_refreshToken!);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _accessToken = responseData['access'];
        await UserPreferences.setTokens(_accessToken!, _refreshToken!);
        notifyListeners();
        return {'status': true, 'message': 'Token refreshed successfully'};
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Failed to refresh token'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to connect to the server: $e'
      };
    }
  }

  Future<void> loadUserFromPrefs() async {
    final user = await UserPreferences.getUser();
    final accessToken = await UserPreferences.getAccessToken();
    final refreshToken = await UserPreferences.getRefreshToken();

    if (user != null && accessToken != null && refreshToken != null) {
      _user = user;
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

