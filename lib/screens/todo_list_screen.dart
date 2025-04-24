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

  // 상세 할 일 입력 대화상자 표시
  void _showDetailedTodoInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetailedTodoInput(onSave: _addDetailedTodo),
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
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
                  padding: const EdgeInsets.all(8), // 패딩값 늘림
                  tabs: const [
                    Tab(text: '기간 없는 작업', height: 40),
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
      floatingActionButton: Container(
        width: 64,
        height: 64,
        margin: const EdgeInsets.only(bottom: 120), // 플러스 버튼을 더 위로 올림
        decoration: NeumorphicStyles.getFABDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: _showDetailedTodoInput,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      // FloatingActionButton 위치 지정
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // 그리드 뷰 레이아웃 구성
  Widget _buildGridView(List<Todo> todos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 가로 방향 아이템 개수
          crossAxisSpacing: 16, // 가로 방향 간격
          mainAxisSpacing: 16, // 세로 방향 간격
          childAspectRatio: 1.0, // 카드 비율 (가로:세로)
        ),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          // 각 할 일에 대한 색상 가져오기, 없으면 기본 색상 사용
          final cardColor =
              _todoColors[todo.id] ?? NeumorphicStyles.cardColors[0];

          return TodoListItem(
            todo: todo,
            onToggle: () => _toggleTodo(todo.id),
            onDelete: () => _deleteTodo(todo.id),
            cardColor: cardColor,
          );
        },
      ),
    );
  }
}
