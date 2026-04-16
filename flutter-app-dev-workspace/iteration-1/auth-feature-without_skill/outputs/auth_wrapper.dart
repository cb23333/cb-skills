import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'login_screen.dart';

/// A wrapper widget that shows either the authenticated home content
/// or the login screen, depending on auth state.
///
/// Usage: Wrap your root widget with [ChangeNotifierProvider<AuthProvider>],
/// then use [AuthWrapper] as the home of your [MaterialApp]. Pass your
/// existing home screen widget as the [homeScreen] parameter.
class AuthWrapper extends StatefulWidget {
  /// The widget to display when the user is authenticated (your home screen).
  final Widget homeScreen;

  const AuthWrapper({super.key, required this.homeScreen});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.tryAutoLogin();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return widget.homeScreen;
    }

    return const LoginScreen();
  }
}
