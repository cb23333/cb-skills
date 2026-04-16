import 'dart:convert';
import 'dart:io';
import 'user_model.dart';

/// Service class handling authentication REST API calls.
class AuthService {
  // TODO: Replace with your actual API base URL
  static const String _baseUrl = 'https://your-api.example.com/api';

  final HttpClient _httpClient;

  AuthService({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  /// Login with email and password.
  /// Returns [UserModel] on success.
  /// Throws [AuthException] on failure.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    return _postRequest(url, {
      'email': email,
      'password': password,
    });
  }

  /// Register a new account with name, email, and password.
  /// Returns [UserModel] on success.
  /// Throws [AuthException] on failure.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    return _postRequest(url, {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  /// Logout the current user (invalidate token on server).
  Future<void> logout(String? token) async {
    if (token == null) return;

    try {
      final url = Uri.parse('$_baseUrl/auth/logout');
      final request = await _httpClient.postUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close();
      await response.drain<void>();
    } catch (_) {
      // Logout is best-effort; don't throw on failure.
    }
  }

  /// Validate an existing token with the server.
  Future<UserModel> validateToken(String token) async {
    final url = Uri.parse('$_baseUrl/auth/me');
    final request = await _httpClient.getUrl(url);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      throw AuthException(_parseErrorMessage(body, 'Token validation failed'));
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return UserModel.fromJson(json['data'] ?? json).copyWith(token: token);
  }

  // -- Private helpers -------------------------------------------------------

  Future<UserModel> _postRequest(Uri url, Map<String, dynamic> payload) async {
    final request = await _httpClient.postUrl(url);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.write(jsonEncode(payload));

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthException(_parseErrorMessage(body, 'Authentication failed'));
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    // Support both { data: {...} } and flat response shapes
    final data = json['data'] ?? json;
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  String _parseErrorMessage(String responseBody, String fallback) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return json['message'] as String? ?? json['error'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}

/// Custom exception for authentication errors.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
