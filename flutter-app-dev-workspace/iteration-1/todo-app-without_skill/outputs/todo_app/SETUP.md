# Todo App - Setup Instructions

## Prerequisites

1. Install Flutter SDK (version 3.0 or higher): https://docs.flutter.dev/get-started/install
2. Install an IDE (VS Code with Flutter extension, or Android Studio)
3. Set up an emulator or connect a physical device

## Quick Start

### Step 1: Create the project

```bash
# Option A: Copy the provided files into a new Flutter project
flutter create todo_app
# Then replace the generated lib/ folder and pubspec.yaml with the provided files

# Option B: If you have the files already, just navigate to the project directory
cd todo_app
```

### Step 2: Install dependencies

```bash
flutter pub get
```

### Step 3: Run the app

```bash
# Run on connected device or emulator
flutter run

# Run on a specific platform
flutter run -d chrome    # Web
flutter run -d windows   # Windows desktop
flutter run -d macos     # macOS desktop
flutter run -d <device>  # Specific device ID
```

### Step 4: Run tests

```bash
flutter test
```

## Project Structure

```
todo_app/
  lib/
    main.dart              # App entry point and root widget
    models/
      todo.dart            # Todo data model
    screens/
      home_screen.dart     # Main screen with task list
    widgets/
      todo_item.dart       # Single todo item card widget
      add_todo_dialog.dart # Dialog for adding new tasks
  test/
    widget_test.dart       # Widget tests
  pubspec.yaml             # Project configuration and dependencies
```

## Features

- Add new tasks via a dialog
- Mark tasks as completed (checkbox toggle)
- Delete tasks via swipe-to-dismiss or delete button
- Filter tasks by: All / Active / Completed
- Empty state with helpful messages
- Material Design 3 theme

## Troubleshooting

- If `flutter pub get` fails, make sure you have an active internet connection
- If `flutter run` fails, check that a device is connected with `flutter devices`
- For web builds, ensure Chrome is installed
