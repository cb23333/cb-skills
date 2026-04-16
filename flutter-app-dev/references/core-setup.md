# Core Setup Guide

Detailed patterns for setting up the core infrastructure of a Flutter app.

## Table of Contents
1. [Theme Setup](#theme-setup)
2. [Router Setup](#router-setup)
3. [Network Client Setup](#network-client-setup)
4. [Local Storage Setup](#local-storage-setup)
5. [App Configuration](#app-configuration)

---

## Theme Setup

### Material 3 Theme with Custom Colors

```dart
// core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Define your brand colors
  static const primary = Color(0xFF6750A4);
  static const secondary = Color(0xFF625B71);
  static const surface = Color(0xFFFFFBFE);
  static const background = Color(0xFFFFFBFE);
}

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primary,
    brightness: Brightness.light,

    // Customize specific components
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primary,
    brightness: Brightness.dark,
  );
}
```

### Theme Provider (for dark mode toggle)

```dart
// core/theme/theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode { light, dark, system }

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode');
    if (saved != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
  }
}
```

---

## Router Setup

### Basic Router with Auth Guard

```dart
// core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.value?.isAuthenticated ?? false;
      final isLoginRoute = state.matchedLocation == '/login';

      // Not logged in and not on login page → redirect to login
      if (!isLoggedIn && !isLoginRoute) return '/login';
      // Logged in and on login page → redirect to home
      if (isLoggedIn && isLoginRoute) return '/';

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
```

### Main Scaffold with Bottom Navigation

```dart
// shared/widgets/main_scaffold.dart
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/profile'); break;
            case 2: context.go('/settings'); break;
          }
        },
      ),
    );
  }
}
```

---

## Network Client Setup

### Dio Client with Interceptors

```dart
// core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  )); // Remove in production

  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add auth token to requests
    final storage = _ref.read(storageProvider);
    final token = await storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired — force logout
      _ref.read(authProvider.notifier).logout();
    }
    handler.next(err);
  }
}
```

### Error Handling Pattern

```dart
// core/network/api_exceptions.dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timed out. Please check your internet.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        final msg = data is Map ? data['message'] ?? 'Unknown error' : 'Unknown error';
        return ApiException(msg, statusCode: status);
      case DioExceptionType.connectionError:
        return ApiException('No internet connection.');
      default:
        return ApiException('Something went wrong. Please try again.');
    }
  }

  @override
  String toString() => message;
}
```

---

## Local Storage Setup

### Simple Key-Value Storage

```dart
// core/storage/local_storage.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

class LocalStorage {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
```

---

## App Configuration

### Environment Configuration

```dart
// core/config/app_config.dart
enum Environment { development, staging, production }

class AppConfig {
  static Environment get environment {
    const String env = String.fromEnvironment('ENV', defaultValue: 'development');
    switch (env) {
      case 'production': return Environment.production;
      case 'staging': return Environment.staging;
      default: return Environment.development;
    }
  }

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.production: return 'https://api.example.com';
      case Environment.staging: return 'https://staging-api.example.com';
      case Environment.development: return 'http://localhost:3000';
    }
  }

  static bool get isDebug => environment != Environment.production;
}
```

Run with a specific environment:
```bash
flutter run --dart-define=ENV=production
```
