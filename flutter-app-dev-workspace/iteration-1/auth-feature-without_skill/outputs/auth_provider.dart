import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import 'user_model.dart';

/// Manages authentication state throughout the app lifecycle.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  // -- Getters --------------------------------------------------------------

  /// The currently authenticated user, or null if not logged in.
  UserModel? get user => _user;

  /// Whether an auth operation is in progress.
  bool get isLoading => _isLoading;

  /// The most recent error message, or null.
  String? get error => _error;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _user != null;

  // -- Public API -----------------------------------------------------------

  /// Attempt to login with [email] and [password].
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.login(email: email, password: password);
      _user = user;
      await _persistToken(user.token);
      _setLoading(false);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Attempt to register with [name], [email], and [password].
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      _user = user;
      await _persistToken(user.token);
      _setLoading(false);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Logout the current user.
  Future<void> logout() async {
    await _authService.logout(_user?.token);
    _user = null;
    await _clearPersistedToken();
    notifyListeners();
  }

  /// Try to restore a previously saved session on app start.
  Future<void> tryAutoLogin() async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        _setLoading(false);
        return;
      }

      final user = await _authService.validateToken(token);
      _user = user;
      _setLoading(false);
      notifyListeners();
    } catch (_) {
      // Token is invalid or expired - clear it silently.
      await _clearPersistedToken();
      _setLoading(false);
    }
  }

  /// Clear the current error message.
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // -- Private helpers ------------------------------------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _persistToken(String? token) async {
    if (token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearPersistedToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
