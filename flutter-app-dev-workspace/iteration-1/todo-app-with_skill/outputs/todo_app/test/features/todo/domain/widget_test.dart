import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/app.dart';

void main() {
  testWidgets('App renders TodoScreen with title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyApp()),
    );

    // Allow async providers to resolve
    await tester.pumpAndSettle();

    // Verify the app bar title is visible
    expect(find.text('My Todos'), findsOneWidget);

    // Verify the empty state message is visible (no todos yet)
    expect(find.text('No tasks here'), findsOneWidget);

    // Verify the FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
