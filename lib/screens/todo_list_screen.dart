import 'package:flutter/material.dart';
import 'dart:math';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../widgets/todo_list_item.dart';
import '../widgets/detailed_todo_input.dart';
import '../utils/neumorphic_styles.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  TodoListScreenState createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  List<Todo> _todos = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  late TabController _tabController;
  final Map<String, Color> _todoColors = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodos();
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
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

        // 모든 할 일에 일관된 색상 할당
        for (var todo in todos) {
          if (!_todoColors.containsKey(todo.id)) {
            _todoColors[todo.id] =
                NeumorphicStyles.cardColors[Random().nextInt(
                  NeumorphicStyles.cardColors.length,
                )];
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      // 오류 로깅: 할 일 목록 불러오기 오류
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 기간 없는 할 일 추가
  Future<void> _addSimpleTodo() async {
    if (_textController.text.isNotEmpty) {
      final todo = Todo.simple(title: _textController.text);

      // 새 할 일에 색상 할당
      _todoColors[todo.id] =
          NeumorphicStyles.cardColors[Random().nextInt(
            NeumorphicStyles.cardColors.length,
          )];

      try {
        await TodoService.addTodo(todo);
        await _loadTodos(); // 목록 새로고침
        _textController.clear();
      } catch (e) {
        // 오류 로깅: 할 일 추가 오류
      }
    }
  }

  // 기간 있는 할 일 추가
  Future<void> _addDetailedTodo(Todo todo) async {
    // 새 할 일에 색상 할당
    _todoColors[todo.id] =
        NeumorphicStyles.cardColors[Random().nextInt(
          NeumorphicStyles.cardColors.length,
        )];

    try {
      await TodoService.addTodo(todo);
      await _loadTodos(); // 목록 새로고침
    } catch (e) {
      // 오류 로깅: 상세 할 일 추가 오류
    }
  }

  // 할 일 상태 토글
  Future<void> _toggleTodo(String id) async {
    try {
      await TodoService.toggleTodoCompleted(id);
      await _loadTodos(); // 목록 새로고침
    } catch (e) {
      // 오류 로깅: 할 일 상태 변경 오류
    }
  }

  // 할 일 삭제
  Future<void> _deleteTodo(String id) async {
    try {
      await TodoService.deleteTodo(id);
      await _loadTodos(); // 목록 새로고침
    } catch (e) {
      // 오류 로깅: 할 일 삭제 오류
    }
  }

  // 상세 할 일 입력 대화상자는 플로팅 버튼에서 직접 호출하민로 메서드 삭제

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
                      color: Color.fromARGB(13, 0, 0, 0),
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

                    // 추가 버튼 (기한 없는 간단한 할 일 추가)
                    GestureDetector(
                      onTap: _addSimpleTodo,
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 16),
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

            // 탭 선택 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13), // 0.05 투명도를 alpha로 변환 (255 * 0.05 = 13)
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: NeumorphicStyles.primaryButtonColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  dividerColor: Colors.transparent, // 구분선 제거
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF888888),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(
                      text: '기간 없는 작업',
                      height: 40,
                      icon: SizedBox(width: 8),
                    ), // 간격 추가
                    Tab(text: '기간 있는 작업', height: 40),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 할 일 목록 부분
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: NeumorphicStyles.primaryButtonColor,
                        ),
                      )
                      : TabBarView(
                        controller: _tabController,
                        children: [
                          // 기간 없는 할 일 탭
                          simpleTodos.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.assignment_outlined,
                                      size: 56,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '기간 없는 할 일을 추가해보세요!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : _buildGridView(simpleTodos),

                          // 기간 있는 할 일 탭
                          detailedTodos.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_note_outlined,
                                      size: 56,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '기간 있는 할 일을 추가해보세요!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : _buildGridView(detailedTodos),
                        ],
                      ),
            ),
          ],
        ),
      ),
      // 할 일 입력 영역에서 이미 기간 없는 할 일 추가 기능이 있으므로
      // 추가 버튼을 제거하여 UI 단순화
    );
  }

  // 리스트 뷰 레이아웃 구성 (유동적 높이의 직사각형 아이템)
  Widget _buildGridView(List<Todo> todos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: todos.length,
        // itemExtent 삭제 - 높이를 자유롭게 설정하여 컨텐츠에 맞춰 자동 조절
        itemBuilder: (context, index) {
          final todo = todos[index];
          // 각 할 일에 대한 색상 가져오기, 없으면 기본 색상 사용
          final cardColor =
              _todoColors[todo.id] ?? NeumorphicStyles.cardColors[0];

          // 연속된 아이템 사이 간격 추가
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TodoListItem(
              todo: todo,
              onToggle: () => _toggleTodo(todo.id),
              onDelete: () => _deleteTodo(todo.id),
              cardColor: cardColor,
            ),
          );
        },
      ),
    );
  }
}
