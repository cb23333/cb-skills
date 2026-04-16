import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  testWidgets('Todo app basic interaction test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const TodoApp());

    // Verify that the app title is shown
    expect(find.text('My Todos'), findsOneWidget);

    // Verify the empty state message
    expect(find.text('No tasks yet.'), findsOneWidget);

    // Tap the FAB to open the add dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify the dialog is shown
    expect(find.text('Add New Task'), findsOneWidget);

    // Enter a task name
    await tester.enterText(find.byType(TextFormField), 'Buy groceries');

    // Tap the Add button
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify the new task is shown in the list
    expect(find.text('Buy groceries'), findsOneWidget);
  });

  testWidgets('Empty task name validation test', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    // Open the add dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Try to add without entering text
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify validation error is shown
    expect(find.text('Please enter a task name'), findsOneWidget);
  });
}
