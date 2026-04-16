---
name: flutter-app-dev
description: >
  End-to-end Flutter mobile app development guide for building production-quality iOS and Android
  applications. Covers project setup, UI design, state management (Riverpod), navigation (GoRouter),
  API integration, local storage, testing, and deployment. Use this skill whenever the user mentions
  Flutter, mobile app, iOS app, Android app, cross-platform app, Dart, widget, pubspec, or wants to
  build any kind of mobile application. Also trigger when the user asks about mobile UI design,
  mobile state management, mobile navigation, app deployment, or any task that involves creating,
  modifying, debugging, or improving a Flutter/Dart codebase — even if they don't explicitly say
  'Flutter'. This includes tasks like adding a login screen, setting up a navigation flow, connecting
  to a REST API, managing app state, or building an APK/IPA.
---

# Flutter App Development

This skill guides you through building production-quality Flutter apps from scratch. It follows a structured workflow that ensures quality at each step, from understanding requirements to deploying the final app.

## Why this workflow matters

Flutter has many ways to do the same thing — multiple state management solutions, routing libraries, architecture patterns. This skill cuts through the noise by giving you a clear, battle-tested path that works well for most apps. The goal is to get you building fast without backing yourself into a corner later.

## Development Workflow

When a user asks you to build or work on a Flutter app, follow these phases in order. Each phase builds on the previous one. Skip phases only if the project already has that foundation in place.

---

### Phase 1: Understand Requirements

Before writing any code, clarify what the app needs. Ask the user about:

- **Core purpose** — What does this app do in 1-2 sentences?
- **Main screens/features** — List the key screens the user will see
- **Data source** — Does it talk to an API? Work offline? Both?
- **Auth needs** — Does it need login/signup?
- **Existing backend** — Is there an API already, or do we need to mock data?

This conversation prevents the most common mistake: building the wrong thing fast.

---

### Phase 2: Project Setup

#### Create the project

```bash
flutter create --org com.example --project-name my_app my_app
cd my_app
```

#### Choose architecture based on complexity

The architecture should match the app's complexity — don't over-engineer a simple app:

| App Size | Screens | State Management | Architecture | Routing |
|----------|---------|-----------------|--------------|---------|
| Simple | < 5 | Provider or Riverpod | Feature-first flat | GoRouter |
| Medium | 5-15 | Riverpod | Feature-first with layers | GoRouter |
| Complex | 15+ | Riverpod or BLoC | Clean architecture | GoRouter nested |

For beginners, **start with Riverpod** even for simple apps — it scales well and has excellent tooling.

#### Set up folder structure (feature-first pattern)

```
lib/
├── main.dart              # App entry point
├── app.dart               # MaterialApp/App configuration
├── core/
│   ├── theme/             # Colors, typography, component themes
│   ├── router/            # GoRouter configuration
│   ├── network/           # Dio client, interceptors
│   ├── storage/           # Local storage helpers
│   └── utils/             # Shared utilities
├── features/
│   └── [feature_name]/
│       ├── data/           # Repository implementations, API calls
│       ├── domain/         # Business logic, providers
│       └── presentation/   # Screens, widgets
└── shared/
    ├── widgets/            # Reusable UI components
    └── models/             # Shared data models
```

This structure keeps related code together. Each feature is self-contained, making it easy to find things and add new features.

#### Add dependencies

Read `references/pubspec-guide.md` for detailed dependency versions and configurations. The essentials:

```yaml
dependencies:
  flutter_riverpod: ^2.5.0      # State management
  go_router: ^14.0.0            # Navigation
  dio: ^5.4.0                   # HTTP client
  freezed_annotation: ^2.4.0    # Immutable models
  json_annotation: ^4.9.0       # JSON serialization

dev_dependencies:
  build_runner: ^2.4.0          # Code generation
  freezed: ^2.5.0               # Model code generation
  json_serializable: ^6.8.0     # JSON code generation
  flutter_test:
    sdk: flutter
```

After adding dependencies:
```bash
flutter pub get
```

If using code generation (freezed, json_serializable):
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### Phase 3: Core Foundation

Build the app's foundation before adding any features. This prevents having to restructure later.

#### 3.1 Theme

Define a consistent look and feel in `core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6750A4), // Change to your brand color
    brightness: Brightness.light,
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6750A4),
    brightness: Brightness.dark,
  );
}
```

Using `colorSchemeSeed` with Material 3 gives you a complete, harmonious color system from a single color.

#### 3.2 Router

Set up GoRouter in `core/router/app_router.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Add routes here as you build features
      GoRoute(
        path: '/',
        builder: (context, state) => const Placeholder(), // Replace with home screen
      ),
    ],
  );
});
```

#### 3.3 App entry point

Wire everything together in `app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'My App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
```

And `main.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}
```

The `ProviderScope` wraps the entire app and makes Riverpod work everywhere.

---

### Phase 4: Feature Development

For each feature, build in this order: **data → domain → presentation**. This way you always have the data and logic ready before building the UI that displays it.

#### Step 1: Data Layer (models + API + repository)

**Define the model** with freezed for immutability and JSON support:

```dart
// features/user/data/user_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    String? avatarUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

Run code generation after creating or modifying models:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Create the repository** that handles data access:

```dart
// features/user/data/user_repository.dart
import 'package:dio/dio.dart';

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<UserModel> getUser(String id) async {
    final response = await _dio.get('/users/$id');
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateUser(String id, {String? name}) async {
    final response = await _dio.patch('/users/$id', data: {
      if (name != null) 'name': name,
    });
    return UserModel.fromJson(response.data);
  }
}
```

The repository is the single source of truth for data access. Widgets never call APIs directly.

#### Step 2: Domain Layer (state + business logic)

**Create a provider** that manages the feature's state:

```dart
// features/user/domain/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = FutureProvider.family<UserModel, String>((ref, userId) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUser(userId);
});
```

For more complex state with user actions, use `AsyncNotifier`:

```dart
// features/auth/domain/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    // Check if user is already logged in on app start
    final token = await ref.read(storageProvider).getToken();
    if (token != null) {
      return AuthState.authenticated(token);
    }
    return const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = await ref.read(authRepositoryProvider).login(email, password);
      await ref.read(storageProvider).saveToken(token);
      return AuthState.authenticated(token);
    });
  }

  Future<void> logout() async {
    await ref.read(storageProvider).deleteToken();
    state = const AsyncValue.data(AuthState.unauthenticated());
  }
}
```

The `AsyncValue.guard` pattern automatically catches errors and wraps them in `AsyncError`. This is cleaner than try-catch in every method.

#### Step 3: Presentation Layer (UI)

**Build screens as composable widgets:**

```dart
// features/user/presentation/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        data: (user) => _UserContent(user: user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorContent(
          message: error.toString(),
          onRetry: () => ref.invalidate(userProvider(userId)),
        ),
      ),
    );
  }
}

class _UserContent extends StatelessWidget {
  final UserModel user;

  const _UserContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(user.name[0].toUpperCase(), style: const TextStyle(fontSize: 32))
                : null,
          ),
          const SizedBox(height: 16),
          Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorContent({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
```

Key pattern: `userAsync.when(data:, loading:, error:)` handles all three states of async data. Always use this — never assume data is loaded.

---

### Phase 5: Navigation & Flow

Connect screens using GoRouter. Add routes as you build each feature:

```dart
// core/router/app_router.dart
GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
  ],
)
```

`ShellRoute` gives you a persistent scaffold (bottom nav, drawer) across multiple screens — perfect for main app navigation.

**Navigate between screens:**
```dart
// Push a route
context.go('/profile');

// Go back
context.pop();

// Pass parameters
context.go('/user/${user.id}');
```

---

### Phase 6: Polish & Quality

#### Testing priorities (in order of value)

1. **Unit tests** for providers and repositories — test business logic
2. **Widget tests** for key screens — test user interactions
3. **Integration tests** for critical flows (login, checkout, etc.)

Example unit test:
```dart
test('login succeeds with valid credentials', () async {
  // Arrange
  final repository = MockAuthRepository();
  when(() => repository.login('test@test.com', 'password'))
      .thenAnswer((_) async => 'token123');

  // Act
  final container = ProviderContainer(overrides: [
    authRepositoryProvider.overrideWithValue(repository),
  ]);
  final auth = container.read(authProvider.notifier);
  await auth.login('test@test.com', 'password');

  // Assert
  final state = container.read(authProvider);
  expect(state.value, equals(AuthState.authenticated('token123')));
});
```

#### Polish checklist

Before considering any screen "done", verify:

- [ ] Loading spinner shows during async operations
- [ ] Error state displays with a retry option
- [ ] Empty state shows helpful content (not just blank space)
- [ ] Pull-to-refresh on list screens
- [ ] Keyboard doesn't cover text fields (use SingleChildScrollView)
- [ ] Responsive layout works on different screen sizes
- [ ] Form validation with clear error messages

---

### Phase 7: Build & Deploy

Read `references/deployment-guide.md` for platform-specific details.

**Android:**
```bash
flutter build appbundle --release    # For Play Store
flutter build apk --release          # For direct distribution
```

**iOS:**
```bash
flutter build ipa --release
```

---

## Key Principles

1. **Start simple, grow as needed.** Don't set up BLoC or clean architecture for a 2-screen app. Add complexity only when the app demands it.

2. **Widgets are cheap.** Break UI into small, focused widgets. A widget should do one thing well. Private widgets (prefixed with `_`) keep the file organized.

3. **State flows down, events flow up.** Parent widgets manage state, child widgets emit events via callbacks. This keeps widgets reusable and testable.

4. **Test what matters most.** Focus on business logic tests. Visual tests catch fewer bugs per minute invested.

5. **Handle all async states.** Every async operation has three states: loading, data, error. Use `AsyncValue.when()` to handle all three.

6. **Use `const` constructors.** Mark widgets as `const` wherever possible. This is Flutter's biggest performance win for free.

7. **Keep the widget tree shallow.** Deep nesting makes code hard to read. Extract widgets early and often.

## Troubleshooting

**Hot reload not working:** Stop the app, then run:
```bash
flutter clean && flutter pub get
```
Restart the app.

**Build errors after dependency changes:**
```bash
flutter clean && flutter pub get
dart run build_runner build --delete-conflicting-outputs  # if using code gen
```

**Platform-specific issues:** Always test on both iOS and Android. Use `flutter doctor` to verify your environment.

**Performance issues:** Use Flutter DevTools to profile:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```
Common causes: missing `const` (unnecessary rebuilds), unbounded lists (use `ListView.builder`), large images not cached.

## Reference Files

These files contain deeper details for when you need them:

- `references/pubspec-guide.md` — Dependency versions, common packages, configuration
- `references/core-setup.md` — Detailed theme, router, and network client setup
- `references/feature-patterns.md` — More code patterns for each feature layer
- `references/deployment-guide.md` — Platform-specific build and deploy instructions
