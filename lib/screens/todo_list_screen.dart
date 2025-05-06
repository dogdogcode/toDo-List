import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../widgets/todo_list_item.dart';
import '../widgets/detailed_todo_input.dart'; // 추가: DetailedTodoInput import
import '../utils/neumorphic_styles.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> _todos = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  final Map<String, Color> _todoColors = {};

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // SharedPreferences에서 할 일 목록 불러오기
  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final todos = await TodoService.getTodos();
      setState(() {
        _todos = todos;

        // 모든 할 일에 고정된 색상 할당: 기간 없는 작업은 cardColors[0], 기간 있는 작업은 cardColors[1]
        for (var todo in todos) {
          if (!_todoColors.containsKey(todo.id)) {
            _todoColors[todo.id] =
                todo.hasDeadline
                    ? NeumorphicStyles.cardColors[1]
                    : NeumorphicStyles.cardColors[0];
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('할 일 목록 불러오기 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 기간 없는 할 일 추가: 고정 색상 할당
  Future<void> _addSimpleTodo() async {
    if (_textController.text.isNotEmpty) {
      final todo = Todo.simple(title: _textController.text);

      _todoColors[todo.id] = NeumorphicStyles.cardColors[0];

      try {
        await TodoService.addTodo(todo);
        await _loadTodos(); // 목록 새로고침
        _textController.clear();
      } catch (e) {
        debugPrint('할 일 추가 오류: $e');
      }
    }
  }

  // 삭제: _addDetailedTodo 메서드는 사용하지 않으므로 제거

  // 할 일 상태 토글
  Future<void> _toggleTodo(String id) async {
    try {
      await TodoService.toggleTodoCompleted(id);
      await _loadTodos(); // 목록 새로고침
    } catch (e) {
      debugPrint('할 일 상태 변경 오류: $e');
    }
  }

  // 할 일 삭제
  Future<void> _deleteTodo(String id) async {
    try {
      await TodoService.deleteTodo(id);
      await _loadTodos(); // 목록 새로고침
    } catch (e) {
      debugPrint('할 일 삭제 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 기간 없는 할 일 목록
    final simpleTodos = _todos.where((todo) => !todo.hasDeadline).toList();

    // 기간 있는 할 일 목록
    final detailedTodos = _todos.where((todo) => todo.hasDeadline).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100], // 배경색 변경
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 앱 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 앱 제목 및 설명
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: NeumorphicStyles.primaryButtonColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.checklist_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '할 일 목록',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 42),
                        child: Text(
                          '오늘의 작업을 관리하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 할 일 입력 부분
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 텍스트 필드
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: '할 일을 입력하세요',
                          hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addSimpleTodo(),
                      ),
                    ),

                    // 추가 버튼
                    GestureDetector(
                      onTap: _addSimpleTodo,
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: NeumorphicStyles.primaryButtonColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 20),

            // 할 일 목록 부분 - 단일 스크롤 뷰로 변경
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: NeumorphicStyles.primaryButtonColor,
                        ),
                      )
                      : _buildCombinedListView(simpleTodos, detailedTodos),
            ),
          ],
        ),
      ),
      // 플로팅 액션 버튼 추가 (상세 작업 추가)
      floatingActionButton: NeumorphicButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder:
                (context) => DetailedTodoInput(
                  onSave: (todo) async {
                    await TodoService.addTodo(todo);
                    await _loadTodos();
                  },
                ),
          );
        },
        width: 60,
        height: 60,
        borderRadius: 30,
        color: NeumorphicStyles.primaryButtonColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildCombinedListView(
    List<Todo> simpleTodos,
    List<Todo> detailedTodos,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 기간 없는 작업 섹션 헤더
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: NeumorphicStyles.textDark,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '기간 없는 작업',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NeumorphicStyles.textDark,
                  ),
                ),
              ],
            ),
          ),
          simpleTodos.isEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 36,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '기간 없는 할 일을 추가해보세요!',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: simpleTodos.length,
                itemBuilder: (context, index) {
                  final todo = simpleTodos[index];
                  final cardColor =
                      _todoColors[todo.id] ?? NeumorphicStyles.cardColors[0];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TodoListItem(
                      todo: todo,
                      onToggle: () => _toggleTodo(todo.id),
                      onDelete: () => _deleteTodo(todo.id),
                      cardColor: cardColor,
                    ),
                  );
                },
              ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.grey, thickness: 1),
          ),
          // 기간 있는 작업 섹션 헤더
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.event_note_outlined,
                  color: NeumorphicStyles.textDark,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '기간 있는 작업',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NeumorphicStyles.textDark,
                  ),
                ),
              ],
            ),
          ),
          detailedTodos.isEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 36,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '기간 있는 할 일을 추가해보세요!',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: detailedTodos.length,
                itemBuilder: (context, index) {
                  final todo = detailedTodos[index];
                  final cardColor =
                      _todoColors[todo.id] ?? NeumorphicStyles.cardColors[1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TodoListItem(
                      todo: todo,
                      onToggle: () => _toggleTodo(todo.id),
                      onDelete: () => _deleteTodo(todo.id),
                      cardColor: cardColor,
                    ),
                  );
                },
              ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
