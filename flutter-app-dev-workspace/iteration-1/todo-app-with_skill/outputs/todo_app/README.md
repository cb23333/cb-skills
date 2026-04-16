# Todo App

A simple, elegant todo application built with Flutter.

## Features
- Add new tasks
- Mark tasks as completed
- Edit task titles
- Delete tasks (swipe to delete)
- Filter tasks (All / Active / Completed)
- Persistent local storage (tasks survive app restarts)
- Material 3 theming with light and dark mode support

## Getting Started

### Prerequisites
- Flutter SDK >= 3.2.0
- Dart SDK >= 3.2.0

### Install dependencies
```bash
cd todo_app
flutter pub get
```

### Run the app
```bash
flutter run
```

### Run tests
```bash
flutter test
```

### Build for release
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Project Structure
```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp configuration
├── core/
│   ├── theme/app_theme.dart           # Material 3 theme
│   └── router/app_router.dart         # GoRouter configuration
├── features/
│   └── todo/
│       ├── data/
│       │   ├── todo_model.dart        # Todo data model
│       │   └── todo_repository.dart   # Local storage repository
│       ├── domain/
│       │   └── todo_provider.dart     # State management (Riverpod)
│       └── presentation/
│           ├── todo_screen.dart       # Main screen
│           └── widgets/
│               ├── add_todo_dialog.dart
│               ├── todo_filter_bar.dart
│               └── todo_item.dart
└── shared/
    └── widgets/
        ├── empty_state.dart
        └── error_view.dart
```

## Tech Stack
- **State Management**: flutter_riverpod
- **Navigation**: go_router
- **Local Storage**: shared_preferences
- **UI**: Material 3 (Material Design 3)
