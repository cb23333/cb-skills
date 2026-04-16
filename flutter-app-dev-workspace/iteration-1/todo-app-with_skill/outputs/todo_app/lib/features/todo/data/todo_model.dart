/// A single todo task.
///
/// Since this is a simple app, we use a plain Dart class instead of
/// freezed-generated code. This avoids the build_runner step while
/// still keeping the model immutable through const constructors.
class TodoModel {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  const TodoModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  /// Create a copy with optional field overrides.
  TodoModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Serialize to JSON for local storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Deserialize from JSON.
  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
