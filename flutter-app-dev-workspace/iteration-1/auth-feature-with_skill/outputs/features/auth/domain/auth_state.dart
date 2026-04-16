import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Represents the current authentication state of the app.
@freezed
sealed class AuthState with _$AuthState {
  /// User is authenticated with a valid token.
  const factory AuthState.authenticated({
    required String token,
    String? userName,
    String? userEmail,
  }) = Authenticated;

  /// User is not logged in.
  const factory AuthState.unauthenticated() = Unauthenticated;

  /// Auth state is being determined (e.g. checking stored token on launch).
  const factory AuthState.initial() = AuthInitial;
}

/// Extension to check auth status concisely.
extension AuthStateX on AuthState {
  bool get isAuthenticated => this is Authenticated;
  bool get isUnauthenticated => this is Unauthenticated;
  bool get isInitial => this is AuthInitial;
}
