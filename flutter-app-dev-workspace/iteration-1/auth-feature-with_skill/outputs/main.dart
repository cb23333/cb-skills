import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/router/app_router.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        // Auth feature dependencies are wired through the core providers.
        // The router and auth_provider reference storageProvider and dioProvider
        // from core/, so no additional overrides are needed.
      ],
      child: const MyApp(),
    ),
  );
}
