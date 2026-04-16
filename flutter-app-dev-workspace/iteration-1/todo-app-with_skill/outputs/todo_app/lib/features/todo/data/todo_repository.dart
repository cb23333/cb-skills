import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_model.dart';

/// Repository that persists todos locally using SharedPreferences.
class TodoRepository {
  static const _storageKey = 'todos';

  Future<List<TodoModel>> getAllTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
    return jsonList
        .map((json) => TodoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAllTodos(List<TodoModel> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(todos.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }
}

/// Provider for the TodoRepository singleton.
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});
