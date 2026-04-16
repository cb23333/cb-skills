import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'auth_model.dart';

/// Provider for the authentication repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

// Placeholder reference — your app should provide this from core/network.
// The auth repository depends on a configured Dio instance.
final dioProvider = Provider<Dio>((ref) {
  throw UnimplementedError(
    'dioProvider must be overridden in your app configuration. '
    'See core/network/api_client.dart',
  );
});
