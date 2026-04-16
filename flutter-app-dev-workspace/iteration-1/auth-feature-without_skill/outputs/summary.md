# Auth Feature - Summary

## Overview

Added a complete email/password authentication feature for a Flutter app that connects to a REST API. The feature includes login, registration, session persistence, and automatic auth state management.

## Files Created

| File | Description |
|------|-------------|
| `user_model.dart` | Data model for the authenticated user (id, email, name, token) with JSON serialization |
| `auth_service.dart` | REST API service layer using `dart:io` HttpClient for login, register, logout, and token validation |
| `auth_provider.dart` | State management using `ChangeNotifier` (Provider pattern). Handles login/register flows, error handling, and token persistence via `shared_preferences` |
| `login_screen.dart` | Login UI with email/password fields, form validation, password visibility toggle, loading state, and navigation to register |
| `register_screen.dart` | Registration UI with name/email/password/confirm-password fields, form validation, password visibility toggle, and loading state |
| `auth_wrapper.dart` | Auth gate widget that shows either the login screen or your existing home screen based on authentication state. Handles auto-login on app start |
| `integration_example.dart` | Complete example showing how to wire everything into your existing app (main.dart setup with Provider, Material app, and AuthWrapper) |
| `api_contracts.md` | Documentation of the expected REST API endpoints and request/response formats |

## Dependencies Required

Add to `pubspec.yaml`:
```yaml
dependencies:
  provider: ^6.1.0
  shared_preferences: ^2.2.0
```

## Integration Steps

1. Copy all `.dart` files into your project (e.g., `lib/auth/`)
2. Add the dependencies listed above
3. Wrap your `MaterialApp` with `ChangeNotifierProvider<AuthProvider>` (see `integration_example.dart`)
4. Use `AuthWrapper` as the home widget, passing your existing home screen
5. Update `AuthService._baseUrl` to point to your actual API server

## Architecture

```
UI Layer (Screens)
  |-- LoginScreen
  |-- RegisterScreen
  |-- AuthWrapper (routing guard)
       |
State Management
  |-- AuthProvider (ChangeNotifier)
       |
Service Layer
  |-- AuthService (HTTP client)
       |
REST API
  |-- POST /auth/login
  |-- POST /auth/register
  |-- POST /auth/logout
  |-- GET  /auth/me
```

## Key Design Decisions

- **Provider pattern** for state management (standard Flutter approach)
- **dart:io HttpClient** for network requests (no extra HTTP package dependency)
- **shared_preferences** for persisting the auth token across app restarts
- **Auto-login** attempts to validate saved token on app launch
- **Form validation** on both login and register screens
- **Error handling** with user-friendly messages from the API
- **AuthException** custom exception class for clean error propagation
