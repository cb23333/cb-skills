import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../network/api_client.dart';
import '../storage/local_storage.dart';
import '../../features/auth/data/auth_providers.dart' as auth_data;
import '../../features/auth/domain/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';

/// Provider for the app's GoRouter instance.
///
/// Includes auth-based redirect logic:
/// - Unauthenticated users are redirected to /login
/// - Authenticated users on /login or /register are redirected to /
final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state so the router rebuilds when login status changes.
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.value?.isAuthenticated ?? false;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isAuthRoute = isLoginRoute || isRegisterRoute;

      // Not logged in and not on auth page -> redirect to login
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Logged in and on auth page -> redirect to home
      if (isLoggedIn && isAuthRoute) return '/';

      return null; // No redirect needed
    },
    routes: [
      // Auth routes (accessible when logged out)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Protected routes (require authentication)
      // Replace the placeholder with your actual home screen.
      GoRoute(
        path: '/',
        builder: (context, state) => const _PlaceholderHomeScreen(),
      ),
    ],
  );
});

/// Placeholder home screen. Replace this with your actual HomeScreen widget.
class _PlaceholderHomeScreen extends ConsumerWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);
    final userName = authAsync.valueOrNull?.userName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 64),
            const SizedBox(height: 16),
            Text('Welcome, $userName!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('You are logged in.'),
          ],
        ),
      ),
    );
  }
}

/// Call this function in your app's provider overrides to wire up
/// the auth feature's dependencies.
///
/// Usage in your app.dart:
/// ```dart
/// return ProviderScope(
///   overrides: setupAuthOverrides(),
///   child: const MyApp(),
/// );
/// ```
List<Override> setupAuthOverrides() {
  return [
    // Wire the auth data layer's dioProvider to the real one
    auth_data.dioProvider.overrideWith((ref) => ref.read(dioProvider)),
    // Wire the auth domain layer's storageProvider to the real one
    storageProvider,
  ];
}
