/// Integration example showing how to wire the auth feature into
/// your existing Flutter app.
///
/// Before using this, add these dependencies to your pubspec.yaml:
///
///   dependencies:
///     provider: ^6.1.0
///     shared_preferences: ^2.2.0
///
/// Then copy the auth files into your project (e.g., lib/auth/).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'auth_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'My App',
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        // AuthWrapper automatically shows Login or Home based on auth state
        home: const AuthWrapper(
          homeScreen: HomeScreen(), // <-- your existing home screen widget
        ),
      ),
    );
  }
}

// -- A placeholder for your existing home screen ----------------------------
// Replace this with your actual HomeScreen widget.

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (user != null) ...[
              Text('Name: ${user.name}'),
              Text('Email: ${user.email}'),
            ],
          ],
        ),
      ),
    );
  }
}
