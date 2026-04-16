import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

/// Root widget that wires together theme, router, and providers.
///
/// To integrate auth into your existing app, merge the provider overrides
/// from [setupAuthOverrides()] into your existing ProviderScope.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'My App',
      // TODO: Replace with your AppTheme import
      // theme: AppTheme.light,
      // darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
