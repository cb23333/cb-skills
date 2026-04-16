/// Represents a single todo task.
class Todo {
  String id;
  String title;
  bool isCompleted;
  DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Toggle the completion status of the todo.
  void toggleComplete() {
    isCompleted = !isCompleted;
  }

  /// Convert to a map for potential serialization.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a Todo from a map.
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
