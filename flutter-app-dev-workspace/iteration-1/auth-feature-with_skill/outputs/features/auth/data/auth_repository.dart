import 'package:dio/dio.dart';
import 'auth_model.dart';

/// Handles all authentication-related API calls.
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Login with email and password.
  /// Returns an [AuthResponse] containing the token and user data.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(response.data);
  }

  /// Register a new account.
  /// Returns an [AuthResponse] containing the token and user data.
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return AuthResponse.fromJson(response.data);
  }

  /// Get the currently authenticated user's profile.
  Future<UserModel> getProfile() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data);
  }

  /// Logout on the server side (invalidate token).
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }
}
