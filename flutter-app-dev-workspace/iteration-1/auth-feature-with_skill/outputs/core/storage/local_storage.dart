import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides a singleton [LocalStorage] instance.
final storageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

/// Simple key-value storage for auth tokens and other persistent data.
///
/// Uses SharedPreferences under the hood. For apps that need to store
/// sensitive data, consider using flutter_secure_storage instead.
class LocalStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  /// Retrieve the stored auth token, or null if not logged in.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Persist the auth token.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Remove the auth token (logout).
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  /// Retrieve the stored refresh token.
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Persist the refresh token.
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }
}
