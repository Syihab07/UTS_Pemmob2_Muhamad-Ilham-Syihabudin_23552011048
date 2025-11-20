import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;

  AuthService() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation for demo purposes
    if (email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Email and password are required'};
    }

    if (!email.contains('@')) {
      return {'success': false, 'message': 'Invalid email format'};
    }

    if (password.length < 6) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters',
      };
    }

    // Save user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', email.split('@')[0]);
    await prefs.setString('userEmail', email);

    _isLoggedIn = true;
    _userName = email.split('@')[0];
    _userEmail = email;
    notifyListeners();

    return {'success': true, 'message': 'Login successful'};
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation for demo purposes
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'All fields are required'};
    }

    if (!email.contains('@')) {
      return {'success': false, 'message': 'Invalid email format'};
    }

    if (password.length < 6) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters',
      };
    }

    // Save user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);

    _isLoggedIn = true;
    _userName = name;
    _userEmail = email;
    notifyListeners();

    return {'success': true, 'message': 'Registration successful'};
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }
}
