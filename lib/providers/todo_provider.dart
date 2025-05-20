import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../utils/neumorphic_styles.dart';

class TodoProvider extends ChangeNotifier {
  bool _isLoading = true;
  List<Todo> _todos = [];
  final Map<String, Color> _todoColors = {};

  // Getters
  bool get isLoading => _isLoading;
  List<Todo> get todos => _todos;
  Map<String, Color> get todoColors => _todoColors;

  // 기간 없는 할 일 목록
  List<Todo> get simpleTodos =>
      _todos.where((todo) => !todo.hasDeadline).toList();

  // 기간 있는 할 일 목록
  List<Todo> get detailedTodos =>
      _todos.where((todo) => todo.hasDeadline).toList();

  // 할 일 목록 불러오기
  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final todos = await TodoService.getTodos();
      _todos = todos;

      // 모든 할 일에 고정된 색상 할당
      for (var todo in todos) {
        if (!_todoColors.containsKey(todo.id)) {
          _todoColors[todo.id] =
              todo.hasDeadline
                  ? NeumorphicStyles.cardColors[1]
                  : NeumorphicStyles.cardColors[0];
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('할 일 목록 불러오기 오류: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // 기간 없는 할 일 추가
  Future<void> addSimpleTodo(String title) async {
    if (title.isNotEmpty) {
      final todo = Todo.simple(title: title);
      _todoColors[todo.id] = NeumorphicStyles.cardColors[0];

      await TodoService.addTodo(todo);
      await loadTodos();
    }
  }

  // 기간 있는 할 일 추가
  Future<void> addDetailedTodo(Todo todo) async {
    _todoColors[todo.id] = NeumorphicStyles.cardColors[1];
    await TodoService.addTodo(todo);
    await loadTodos();
  }

  // 할 일 상태 토글
  Future<void> toggleTodo(String id) async {
    await TodoService.toggleTodoCompleted(id);
    await loadTodos();
  }

  // 할 일 삭제
  Future<void> deleteTodo(String id) async {
    await TodoService.deleteTodo(id);
    await loadTodos();
  }

  // 특정 날짜의 할 일 가져오기
  List<Todo> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _todos.where((todo) {
      if (todo.hasDeadline && todo.deadline != null) {
        final todoDate = DateTime(
          todo.deadline!.year,
          todo.deadline!.month,
          todo.deadline!.day,
        );
        return normalizedDay.isAtSameMomentAs(todoDate);
      }
      return false;
    }).toList();
  }
}
