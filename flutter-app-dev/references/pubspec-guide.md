# Pubspec Guide

## Table of Contents
1. [Core Dependencies](#core-dependencies)
2. [Optional Dependencies](#optional-dependencies-by-need)
3. [Dev Dependencies](#dev-dependencies)
4. [Full Example pubspec.yaml](#full-example)
5. [Dependency Management Tips](#dependency-management-tips)

---

## Core Dependencies

These are the recommended packages for most Flutter apps:

### State Management
```yaml
dependencies:
  flutter_riverpod: ^2.5.0
```
Riverpod is compile-time safe, testable, and works well at any scale.

### Navigation
```yaml
dependencies:
  go_router: ^14.0.0
```
Declarative routing with deep linking support.

### Networking
```yaml
dependencies:
  dio: ^5.4.0
```
More features than http package: interceptors, form data, cancellation.

### Models
```yaml
dependencies:
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
```

---

## Optional Dependencies (by need)

### Local Storage
```yaml
# Simple key-value storage
dependencies:
  shared_preferences: ^2.2.0

# Secure storage (tokens, passwords)
dependencies:
  flutter_secure_storage: ^9.0.0

# Local database
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

# SQLite
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.0
```

### Image Handling
```yaml
dependencies:
  cached_network_image: ^3.3.0   # Cached image loading
  image_picker: ^1.0.0           # Camera/gallery picker
```

### Forms & Validation
```yaml
dependencies:
  formz: ^0.7.0                  # Form input validation
```

### Date & Time
```yaml
dependencies:
  intl: ^0.19.0                  # Date formatting, localization
```

### Animations
```yaml
dependencies:
  flutter_animate: ^4.3.0        # Declarative animations
```

### Push Notifications
```yaml
dependencies:
  firebase_messaging: ^14.2.0
  firebase_core: ^2.24.0
```

### Analytics
```yaml
dependencies:
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.0
```

---

## Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  flutter_lints: ^3.0.0
  mocktail: ^1.0.0              # Mocking for tests
```

---

## Full Example

```yaml
name: my_app
description: My Flutter application
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  go_router: ^14.0.0
  dio: ^5.4.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  shared_preferences: ^2.2.0
  cached_network_image: ^3.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  flutter_lints: ^3.0.0
  mocktail: ^1.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/fonts/
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

---

## Dependency Management Tips

### Adding a new dependency
```bash
# Add and get in one command
flutter pub add dio

# Add dev dependency
flutter pub add --dev mocktail
```

### Resolving version conflicts
```bash
# Show dependency tree
flutter pub deps

# Force resolve
flutter pub get

# Nuclear option
flutter clean && flutter pub get
```

### Code generation
```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (rebuilds on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

### Keeping dependencies updated
```bash
# Check for outdated packages
flutter pub outdated

# Update to latest compatible versions
flutter pub upgrade

# Update a specific package
flutter pub upgrade dio
```
