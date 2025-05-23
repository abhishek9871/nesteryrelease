import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nestery_flutter/models/user.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  String? _refreshToken;
  User? _user;
  DateTime? _expiryDate;
  
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _expiryDate != null && _expiryDate!.isAfter(DateTime.now());
  String? get token => _token;
  User? get user => _user;
  
  AuthProvider() {
    _autoLogin();
  }
  
  // Auto login from stored credentials
  Future<void> _autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return;
    }
    
    final userData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate']);
    
    if (expiryDate.isBefore(DateTime.now())) {
      // Token expired, try to refresh
      try {
        await _refreshAuth(userData['refreshToken']);
      } catch (error) {
        // Refresh failed, user needs to login again
        return;
      }
    } else {
      _token = userData['token'];
      _refreshToken = userData['refreshToken'];
      _user = User.fromJson(userData['user']);
      _expiryDate = expiryDate;
      notifyListeners();
    }
  }
  
  // Register new user
  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    
    try {
      final url = '${dotenv.env['API_URL']}/auth/register';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        throw ApiException(
          message: responseData['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
      
      // Auto login after registration
      await login(email, password);
    } catch (error) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Login user
  Future<void> login(String email, String password) async {
    _setLoading(true);
    
    try {
      final url = '${dotenv.env['API_URL']}/auth/login';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        throw ApiException(
          message: responseData['message'] ?? 'Authentication failed',
          statusCode: response.statusCode,
        );
      }
      
      _token = responseData['accessToken'];
      _refreshToken = responseData['refreshToken'];
      _user = User.fromJson(responseData['user']);
      _expiryDate = DateTime.now().add(
        Duration(seconds: responseData['expiresIn'] ?? 3600),
      );
      
      // Save user data to shared preferences
      _saveUserData();
      
      // Set auto refresh timer
      _setAutoRefreshTimer();
      
      notifyListeners();
      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Refresh authentication token
  Future<void> _refreshAuth(String refreshToken) async {
    try {
      final url = '${dotenv.env['API_URL']}/auth/refresh-token';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'refreshToken': refreshToken,
        }),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        throw ApiException(
          message: responseData['message'] ?? 'Token refresh failed',
          statusCode: response.statusCode,
        );
      }
      
      _token = responseData['accessToken'];
      _refreshToken = responseData['refreshToken'];
      _expiryDate = DateTime.now().add(
        Duration(seconds: responseData['expiresIn'] ?? 3600),
      );
      
      // Save updated user data
      _saveUserData();
      
      // Set auto refresh timer
      _setAutoRefreshTimer();
      
      notifyListeners();
    } catch (error) {
      // If refresh fails, logout user
      logout();
      rethrow;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _user = null;
    _expiryDate = null;
    
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    
    notifyListeners();
  }
  
  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> userData) async {
    _setLoading(true);
    
    try {
      final url = '${dotenv.env['API_URL']}/users/profile';
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(userData),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        throw ApiException(
          message: responseData['message'] ?? 'Profile update failed',
          statusCode: response.statusCode,
        );
      }
      
      // Update user data
      _user = User.fromJson(responseData);
      
      // Save updated user data
      _saveUserData();
      
      notifyListeners();
      _setLoading(false);
    } catch (error) {
      _setLoading(false);
      rethrow;
    }
  }
  
  // Save user data to shared preferences
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'refreshToken': _refreshToken,
      'user': _user?.toJson(),
      'expiryDate': _expiryDate?.toIso8601String(),
    });
    prefs.setString('userData', userData);
  }
  
  // Set auto refresh timer
  void _setAutoRefreshTimer() {
    if (_expiryDate == null || _refreshToken == null) return;
    
    // Calculate time to refresh (5 minutes before expiry)
    final timeToExpiry = _expiryDate!.difference(DateTime.now());
    final timeToRefresh = timeToExpiry - const Duration(minutes: 5);
    
    if (timeToRefresh.isNegative) {
      // Already need to refresh
      _refreshAuth(_refreshToken!);
      return;
    }
    
    // Set timer to refresh token
    Future.delayed(timeToRefresh, () {
      if (_refreshToken != null) {
        _refreshAuth(_refreshToken!);
      }
    });
  }
  
  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
