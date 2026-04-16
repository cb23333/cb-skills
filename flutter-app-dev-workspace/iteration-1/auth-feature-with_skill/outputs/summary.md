# Auth Feature Summary

## What was produced

A complete authentication feature for a Flutter app using **Riverpod + GoRouter + Dio**, following the `flutter-app-dev` skill's feature-first architecture (data -> domain -> presentation layers).

## Files Created

### Feature Layer: `features/auth/`

| File | Purpose |
|------|---------|
| `data/auth_model.dart` | Freezed data models: `AuthResponse`, `UserModel`, `LoginRequest`, `RegisterRequest` |
| `data/auth_repository.dart` | API calls: login, register, getProfile, logout (via Dio) |
| `data/auth_providers.dart` | Provider for `AuthRepository` with Dio dependency |
| `domain/auth_state.dart` | Freezed state class: `AuthState.authenticated`, `.unauthenticated`, `.initial` |
| `domain/auth_provider.dart` | `AuthNotifier` (AsyncNotifier) managing login/register/logout lifecycle + token storage |
| `presentation/login_screen.dart` | Login UI with email/password form, validation, loading state, error feedback |
| `presentation/register_screen.dart` | Registration UI with name/email/password/confirm fields, validation |

### Core Infrastructure: `core/`

| File | Purpose |
|------|---------|
| `network/api_client.dart` | Dio provider with `AuthInterceptor` (auto-attaches Bearer token, handles 401) |
| `network/api_exceptions.dart` | `ApiException` with user-friendly error messages for all HTTP status codes |
| `storage/local_storage.dart` | SharedPreferences-based token storage (`getToken`, `saveToken`, `deleteToken`) |
| `router/app_router.dart` | GoRouter with auth-based redirect guard, login/register/home routes |

### App Entry

| File | Purpose |
|------|---------|
| `app.dart` | Root `ConsumerWidget` wiring router to `MaterialApp.router` |
| `main.dart` | Entry point with `ProviderScope` |

## Architecture

```
features/auth/
  data/       -> API models (freezed), repository (Dio HTTP calls)
  domain/     -> AuthState (freezed), AuthNotifier (Riverpod AsyncNotifier)
  presentation/ -> LoginScreen, RegisterScreen (ConsumerStatefulWidget)
core/
  network/    -> Dio client, auth interceptor, API exceptions
  storage/    -> LocalStorage (SharedPreferences token persistence)
  router/     -> GoRouter with auth redirect guard
```

## How to Integrate into Your Existing App

1. **Copy the `features/auth/` directory** into your `lib/features/` directory.

2. **Copy the `core/` files** into your `lib/core/` directory. If you already have `api_client.dart` or `local_storage.dart`, merge the auth-related code into your existing files.

3. **Update your `pubspec.yaml`** with required dependencies:
   ```yaml
   dependencies:
     flutter_riverpod: ^2.5.0
     go_router: ^14.0.0
     dio: ^5.4.0
     freezed_annotation: ^2.4.0
     json_annotation: ^4.9.0
     shared_preferences: ^2.2.0

   dev_dependencies:
     build_runner: ^2.4.0
     freezed: ^2.5.0
     json_serializable: ^6.8.0
   ```

4. **Run code generation** (for freezed models):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Update your router** to use `routerProvider` from `core/router/app_router.dart`, or copy the redirect logic and routes into your existing router.

6. **Set your API base URL** in `core/network/api_client.dart` (replace `https://api.example.com`).

## Auth Flow

1. App starts -> `AuthNotifier.build()` checks local storage for a saved token.
2. If token exists -> state is `authenticated`, router allows access to protected routes.
3. If no token -> state is `unauthenticated`, router redirects to `/login`.
4. User logs in or registers -> API call -> token saved to storage -> state becomes `authenticated`.
5. All subsequent API calls include `Authorization: Bearer <token>` via the interceptor.
6. If a 401 response is received -> interceptor forces logout -> user returns to login screen.

## API Endpoints Expected

| Endpoint | Method | Body | Response |
|----------|--------|------|----------|
| `/auth/login` | POST | `{ email, password }` | `{ token, user: { id, email, name, ... } }` |
| `/auth/register` | POST | `{ name, email, password, password_confirmation }` | `{ token, user: { id, email, name, ... } }` |
| `/auth/me` | GET | - | `{ id, email, name, ... }` |
| `/auth/logout` | POST | - | - |

Adjust the endpoint paths and response shapes in `auth_repository.dart` to match your actual backend API.
