import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoService {
  static const String _todosKey = 'todos';

  // 할 일 목록 불러오기
  static Future<List<Todo>> getTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString(_todosKey);

    if (todosString == null) {
      return [];
    }

    final List<dynamic> todosJson = jsonDecode(todosString);
    return todosJson.map((json) => Todo.fromJson(json)).toList();
  }

  // 할 일 목록 저장하기
  static Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final String todosString = jsonEncode(
      todos.map((todo) => todo.toJson()).toList(),
    );
    await prefs.setString(_todosKey, todosString);
  }

  // 단일 할 일 추가하기
  static Future<void> addTodo(Todo todo) async {
    final todos = await getTodos();
    todos.add(todo);
    await saveTodos(todos);
  }

  // 할 일 업데이트하기
  static Future<void> updateTodo(Todo updatedTodo) async {
    final todos = await getTodos();
    final index = todos.indexWhere((todo) => todo.id == updatedTodo.id);

    if (index != -1) {
      todos[index] = updatedTodo;
      await saveTodos(todos);
    }
  }

  // 할 일 삭제하기
  static Future<void> deleteTodo(String id) async {
    final todos = await getTodos();
    todos.removeWhere((todo) => todo.id == id);
    await saveTodos(todos);
  }

  // 할 일 완료 상태 토글하기
  static Future<void> toggleTodoCompleted(String id) async {
    final todos = await getTodos();
    final index = todos.indexWhere((todo) => todo.id == id);

    if (index != -1) {
      todos[index].toggleCompleted();
      await saveTodos(todos);
    }
  }
}
