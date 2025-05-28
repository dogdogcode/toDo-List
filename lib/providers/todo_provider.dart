import 'package:flutter/foundation.dart';
import '../models/todo_item.dart';
import '../services/database_service.dart';

class TodoProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<TodoItem> _allTodos = [];
  List<TodoItem> _simpleTasks = [];
  List<TodoItem> _deadlineTasks = [];
  bool _isLoading = false;

  // Getters
  List<TodoItem> get allTodos => _allTodos;
  List<TodoItem> get simpleTasks => _simpleTasks;
  List<TodoItem> get deadlineTasks => _deadlineTasks;
  bool get isLoading => _isLoading;

  // 통계 정보
  int get totalTasks => _allTodos.length;
  int get completedTasks => _allTodos.where((todo) => todo.isCompleted).length;
  int get pendingTasks => _allTodos.where((todo) => !todo.isCompleted).length;
  int get overdueTasks => _allTodos.where((todo) => todo.isOverdue).length;

  // 초기 데이터 로드
  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTodos = await _databaseService.getAllTodos();
      _simpleTasks = await _databaseService.getSimpleTasks();
      _deadlineTasks = await _databaseService.getDeadlineTasks();
    } catch (e) {
      debugPrint('할일 로드 중 오류 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 할일 추가
  Future<bool> addTodo(TodoItem todo) async {
    try {
      final id = await _databaseService.insertTodo(todo);
      if (id > 0) {
        await loadTodos(); // 데이터 다시 로드
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('할일 추가 중 오류 발생: $e');
      return false;
    }
  }

  // 할일 상태 토글 (완료/미완료)
  Future<bool> toggleTodoStatus(TodoItem todo) async {
    try {
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        updatedAt: DateTime.now(),
      );
      
      final result = await _databaseService.updateTodo(updatedTodo);
      if (result > 0) {
        await loadTodos(); // 데이터 다시 로드
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('할일 상태 변경 중 오류 발생: $e');
      return false;
    }
  }

  // 할일 업데이트
  Future<bool> updateTodo(TodoItem todo) async {
    try {
      final result = await _databaseService.updateTodo(todo);
      if (result > 0) {
        await loadTodos(); // 데이터 다시 로드
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('할일 업데이트 중 오류 발생: $e');
      return false;
    }
  }

  // 할일 삭제
  Future<bool> deleteTodo(int id) async {
    try {
      final result = await _databaseService.deleteTodo(id);
      if (result > 0) {
        await loadTodos(); // 데이터 다시 로드
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('할일 삭제 중 오류 발생: $e');
      return false;
    }
  }

  // 완료된 할일들 모두 삭제
  Future<bool> deleteCompletedTodos() async {
    try {
      final result = await _databaseService.deleteCompletedTodos();
      if (result >= 0) {
        await loadTodos(); // 데이터 다시 로드
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('완료된 할일 삭제 중 오류 발생: $e');
      return false;
    }
  }

  // 특정 타입의 할일들 필터링
  List<TodoItem> getFilteredTodos({bool? isCompleted, bool? hasDeadline}) {
    return _allTodos.where((todo) {
      if (isCompleted != null && todo.isCompleted != isCompleted) {
        return false;
      }
      if (hasDeadline != null && todo.hasDeadline != hasDeadline) {
        return false;
      }
      return true;
    }).toList();
  }
}
