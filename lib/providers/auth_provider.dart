import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';
import 'package:kissima/modals/user_modal.dart';
import 'package:kissima/modals/user_preference.dart';
import 'package:kissima/services/auth_requests.dart';

enum Status {
  notLoggedIn,
  notRegistered,
  loggedIn,
  registered,
  authenticating,
  registering,
  loggedOut,
  resettingPassword,
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.notLoggedIn;
  Status _registeredStatus = Status.notRegistered;
  Status _resetPasswordStatus = Status.notLoggedIn;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredStatus => _registeredStatus;
  Status get resetPasswordStatus => _resetPasswordStatus;

  bool get isLoggedIn => _loggedInStatus == Status.loggedIn;

  AuthProvider() {
    _initAuthState();
  }

  Future<void> _initAuthState() async {
    final user = await UserPreferences.getUser();
    if (user != null && user.accessToken.isNotEmpty) {
      _loggedInStatus = Status.loggedIn;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    Map<String, dynamic> result;
    final Map<String, dynamic> logInData = {
      'username': username,
      'password': password,
    };

    _loggedInStatus = Status.authenticating;
    notifyListeners();

    try {
      final response = await AuthRequests.login(logInData);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        developer.log("Login response: ${response.statusCode} ${response.body}");
        User authenticatedUser = User.fromJson(responseData);
        await UserPreferences.saveUser(authenticatedUser);
        _loggedInStatus = Status.loggedIn;
        result = {
          "status": true,
          "message": responseData['message'] ?? "Login successful",
          "user": authenticatedUser
        };
      } else {
        _loggedInStatus = Status.notLoggedIn;
        result = {
          "status": false,
          "message": jsonDecode(response.body)['error'] ?? "Login failed"
        };
      }
    } catch (e) {
      _loggedInStatus = Status.notLoggedIn;
      result = {
        "status": false,
        "message": "Error: ${e.toString()}"
      };
    }

    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    Map<String, dynamic> result;
    final Map<String, dynamic> resetData = {
      'email': email,
    };

    _resetPasswordStatus = Status.resettingPassword;
    notifyListeners();

    try {
      final response = await AuthRequests.resetPasswordEmail(resetData);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        result = {
          "status": true,
          "message": responseData['detail'] ?? "Password reset email sent"
        };
      } else {
        result = {
          "status": false,
          "message": jsonDecode(response.body)['error'] ?? "Failed to send email"
        };
      }
    } catch (e) {
      result = {
        "status": false,
        "message": "Error: ${e.toString()}"
      };
    }

    _resetPasswordStatus = Status.notLoggedIn;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> changePassword(String token, String newPassword) async {
    Map<String, dynamic> result;
    final Map<String, dynamic> resetData = {
      'Token': token,
      'new_password': newPassword,
    };

    _resetPasswordStatus = Status.resettingPassword;
    notifyListeners();

    try {
      final response = await AuthRequests.resetPassword(resetData);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        result = {
          "status": true,
          "message": responseData['message'] ?? "Password reset successfully"
        };
      } else {
        result = {
          "status": false,
          "message": jsonDecode(response.body)['error'] ?? "Failed to reset password"
        };
      }
    } catch (e) {
      result = {
        "status": false,
        "message": "Error: ${e.toString()}"
      };
    }

    _resetPasswordStatus = Status.notLoggedIn;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String middleName,
    required String username,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final Map<String, dynamic> registrationData = {
      "first_name": firstName,
      "username": username,
      "middle_name": middleName,
      "last_name": lastName,
      "email": email,
      "password": password,
      "phone_number": phoneNumber,
    };

    _registeredStatus = Status.registering;
    notifyListeners();

    try {
      final response = await AuthRequests.register(registrationData);
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        final loginResult = await login(username, password);
        if (loginResult['status']) {
          _registeredStatus = Status.registered;
          return {
            "status": true,
            "message": responseData['message'] ?? "Registered successfully",
            "data": loginResult['user']
          };
        } else {
          _registeredStatus = Status.notRegistered;
          return {
            "status": false,
            "message": "Registration succeeded but login failed",
            "data": responseData
          };
        }
      } else {
        _registeredStatus = Status.notRegistered;
        return {
          "status": false,
          "message": responseData['error'] ?? "Registration failed",
          "data": responseData
        };
      }
    } catch (e) {
      _registeredStatus = Status.notRegistered;
      return {
        "status": false,
        "message": "Error: ${e.toString()}",
        "data": null
      };
    } finally {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> logout() async {
    _loggedInStatus = Status.loggedOut;
    notifyListeners();

    try {
      final user = await UserPreferences.getUser();
      final refreshToken = user?.refreshToken ?? '';
      final response = await AuthRequests.logout(refreshToken);
      await UserPreferences.removeUser();
      return {
        "status": true,
        "message": jsonDecode(response.body)['message'] ?? "Logged out successfully"
      };
    } catch (e) {
      return {
        "status": false,
        "message": "Error: ${e.toString()}"
      };
    }
  }

  Future<Map<String, dynamic>> feed(double portion) async {
    final Map<String, dynamic> feedData = {
      'portion': portion,
    };

    try {
      final response = await AuthRequests.feed(feedData);
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          "status": true,
          "message": responseData['message'] ?? "Feeding triggered successfully",
          "data": responseData['data']
        };
      } else if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed['status']) {
          return await feed(portion);
        } else {
          return {
            "status": false,
            "message": "Authentication failed, please log in again"
          };
        }
      } else {
        return {
          "status": false,
          "message": jsonDecode(response.body)['error'] ?? "Failed to trigger feeding"
        };
      }
    } catch (e) {
      return {
        "status": false,
        "message": "Error: ${e.toString()}"
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? email,
    String? phoneNumber,
  }) async {
    final Map<String, dynamic> profileData = {};
    if (firstName != null) profileData['first_name'] = firstName;
    if (email != null) profileData['email'] = email;
    if (phoneNumber != null) profileData['phone_number'] = phoneNumber;

    try {
      final response = await AuthRequests.updateProfile(profileData);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = await UserPreferences.getUser();
        if (user != null) {
          final updatedUser = User.fromJson({
            ...UserSerializer(user).data,
            ...responseData['data'],
            'tokens': {
              'access': user.accessToken,
              'refresh': user.refreshToken,
            },
          });
          await UserPreferences.saveUser(updatedUser);
        }
        return {
          "status": true,
          "message": responseData['message'] ?? "Profile updated successfully",
          "data": responseData['data']
        };
      } else if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed['status']) {
          return await updateProfile(
            firstName: firstName,
            email: email,
            phoneNumber: phoneNumber,
          );
        } else {
          return {
            "status": false,
            "message": "Authentication failed, please log in again"
          };
        }
      } else {
        return {
          "status": false,
          "message": jsonDecode(response.body)['error'] ?? "Failed to update profile"
        };
      }
    } catch (e) {
      return {
        "status": false,
        "message": "Error: ${e.toString()}"
      };
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final user = await UserPreferences.getUser();
      if (user?.refreshToken == null) {
        return {
          "status": false,
          "message": "No refresh token available"
        };
      }
      final response = await AuthRequests.refreshToken(user!.refreshToken!);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newUser = User.fromJson({
          ...UserSerializer(user).data,
          'tokens': {
            'access': data['access'],
            'refresh': user.refreshToken,
          },
        });
        await UserPreferences.saveUser(newUser);
        return {
          "status": true,
          "message": "Token refreshed successfully"
        };
      } else {
        await UserPreferences.removeUser();
        _loggedInStatus = Status.notLoggedIn;
        notifyListeners();
        return {
          "status": false,
          "message": jsonDecode(response.body)['error'] ?? "Failed to refresh token"
        };
      }
    } catch (e) {
      _loggedInStatus = Status.notLoggedIn;
      notifyListeners();
      return {
        "status": false,
        "message": "Error: ${e.toString()}"
      };
    }
  }
}

class UserSerializer {
  final User user;

  UserSerializer(this.user);

  Map<String, dynamic> get data => {
    'id': user.id,
    'username': user.username,
    'email': user.email,
    'first_name': user.firstName,
    'last_name': user.lastName,
    'phone_number': user.phone,
    'userType': user.userType,
  };
}