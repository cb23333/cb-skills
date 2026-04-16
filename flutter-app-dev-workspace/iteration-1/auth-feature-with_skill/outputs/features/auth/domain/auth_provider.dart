import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_providers.dart';
import 'auth_state.dart';

/// Placeholder — override this in your app's core/storage setup.
/// Should provide methods: getToken(), saveToken(), deleteToken().
final storageProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(
    'storageProvider must be overridden. See core/storage/local_storage.dart',
  );
});

/// Interface for storage operations needed by auth.
abstract class StorageService {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}

/// Provider that manages the full authentication lifecycle.
///
/// On build it checks for an existing token in local storage.
/// Exposes [login], [register], and [logout] actions.
final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // On app start, check if there is a stored token.
    final storage = ref.read(storageProvider);
    final token = await storage.getToken();
    if (token != null) {
      return AuthState.authenticated(token: token);
    }
    return const AuthState.unauthenticated();
  }

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.login(email: email, password: password);
      final storage = ref.read(storageProvider);
      await storage.saveToken(response.token);
      return AuthState.authenticated(
        token: response.token,
        userName: response.user.name,
        userEmail: response.user.email,
      );
    });
  }

  /// Register a new account.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final storage = ref.read(storageProvider);
      await storage.saveToken(response.token);
      return AuthState.authenticated(
        token: response.token,
        userName: response.user.name,
        userEmail: response.user.email,
      );
    });
  }

  /// Logout and clear stored credentials.
  Future<void> logout() async {
    final storage = ref.read(storageProvider);
    await storage.deleteToken();
    // Best-effort server-side logout; ignore errors.
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {}
    state = const AsyncData(AuthState.unauthenticated());
  }
}
