import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todo/data/todo_model.dart';

void main() {
  group('TodoModel', () {
    test('copyWith returns a new instance with updated fields', () {
      final todo = TodoModel(
        id: '1',
        title: 'Buy milk',
        isCompleted: false,
        createdAt: DateTime(2025, 1, 1),
      );

      final updated = todo.copyWith(isCompleted: true, title: 'Buy almond milk');

      expect(updated.id, '1');
      expect(updated.title, 'Buy almond milk');
      expect(updated.isCompleted, true);
      expect(updated.createdAt, DateTime(2025, 1, 1));
    });

    test('toJson / fromJson round-trip preserves data', () {
      final todo = TodoModel(
        id: 'abc',
        title: 'Test task',
        isCompleted: true,
        createdAt: DateTime(2025, 6, 15, 10, 30),
      );

      final json = todo.toJson();
      final restored = TodoModel.fromJson(json);

      expect(restored.id, todo.id);
      expect(restored.title, todo.title);
      expect(restored.isCompleted, todo.isCompleted);
      expect(restored.createdAt, todo.createdAt);
    });
  });
}
