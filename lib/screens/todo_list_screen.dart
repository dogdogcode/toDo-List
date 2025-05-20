import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/detailed_todo_input.dart';
import '../utils/neumorphic_styles.dart';
import '../widgets/optimized_todo_list.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _textController = TextEditingController();

  // 스크롤 애니메이션을 위한 변수
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  final double _appBarHeight = 190.0; // 헤더 높이 최적화

  @override
  void initState() {
    super.initState();
    // Provider를 통한 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).loadTodos();
    });

    // 스크롤 리스너 추가
    _scrollController.addListener(_scrollListener);
  }

  // 스크롤 이벤트 리스너
  void _scrollListener() {
    // 스크롤 위치가 50을 넘어가면 헤더 축소
    if (_scrollController.offset > 50 && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    } else if (_scrollController.offset <= 50 && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    // 스크롤 리스너 제거
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // 기간 없는 할 일 추가 핸들러
  Future<void> _addSimpleTodo() async {
    if (_textController.text.isNotEmpty) {
      await Provider.of<TodoProvider>(
        context,
        listen: false,
      ).addSimpleTodo(_textController.text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    
    // Provider에서 상태 읽기
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return Scaffold(
          backgroundColor: NeumorphicStyles.backgroundColor,
          body: Column(
            children: [
              // 애니메이트된 헤더 영역 - 메모이제이션
              _buildAnimatedHeader(),
              // 할 일 목록 부분 - 단일 스크롤 뷰로 변경
              Expanded(
                child:
                    todoProvider.isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: NeumorphicStyles.primaryButtonColor,
                          ),
                        )
                        : _buildCombinedListView(todoProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  // 헤더 영역을 메서드로 분리
  Widget _buildAnimatedHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isCollapsed ? 80 : _appBarHeight,
      child: _isCollapsed ? _buildCollapsedHeader() : _buildExpandedHeader(),
    );
  }

  // 축소된 헤더
  Widget _buildCollapsedHeader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 앱 제목만 간단히 표시
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
          ],
        ),
      ),
    );
  }

  // 확장된 헤더
  Widget _buildExpandedHeader() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          // 제목 및 설명 부분
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
                    // 설명 텍스트
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
          _buildTodoInputSection(),
        ],
      ),
    );
  }

  // 할 일 입력 부분
  Widget _buildTodoInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 기본 할 일 입력창 - NeumorphicContainer 사용
          NeumorphicContainer(
            height: 56,
            borderRadius: 16,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // 텍스트 입력 필드
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '기본 할 일을 입력하세요',
                      hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addSimpleTodo(),
                  ),
                ),
                // 추가 버튼
                NeumorphicButton(
                  onPressed: _addSimpleTodo,
                  width: 40,
                  height: 40,
                  borderRadius: 12,
                  color: NeumorphicStyles.primaryButtonColor,
                  child: const Center(
                    child: Icon(
                      Icons.add_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 기간 있는 할 일 추가 버튼
          NeumorphicButton(
            onPressed: () => _showDetailedTodoInput(context),
            width: double.infinity,
            height: 46,
            borderRadius: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  color: NeumorphicStyles.primaryButtonColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '기간이 있는 할 일 추가',
                  style: TextStyle(
                    color: NeumorphicStyles.textDark,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 상세 할 일 입력 모달 표시
  void _showDetailedTodoInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DetailedTodoInput(
            onSave: (todo) async {
              await Provider.of<TodoProvider>(
                context,
                listen: false,
              ).addDetailedTodo(todo);
            },
          ),
    );
  }

  // 통합된 목록 뷰
  Widget _buildCombinedListView(TodoProvider provider) {
    final simpleTodos = provider.simpleTodos;
    final detailedTodos = provider.detailedTodos;

    // 네비게이션 바 높이 + 여백 계산 (하단 여유 공간)
    final bottomNavHeight = 100.0;  // 네비게이션 바 높이 + 여유 공간

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),  // iOS 스타일 스크롤 효과로 개선
      child: Padding(
        // 하단에 네비게이션 바 만큼 패딩 추가
        padding: EdgeInsets.only(bottom: bottomNavHeight),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 기간 없는 할 일 섹션
          _buildSectionHeader(
            title: '기간 없는 할 일',
            icon: Icons.checklist,
            color: NeumorphicStyles.cardColors[0],
            count: simpleTodos.length,
            iconColor: NeumorphicStyles.primaryButtonColor,
          ),

          // 할 일 목록 또는 빈 상태 표시
          simpleTodos.isEmpty
              ? _buildEmptyState(
                icon: Icons.add_task,
                message: '기간 없는 할 일을 추가해보세요!',
                color: NeumorphicStyles.cardColors[0],
                iconColor: NeumorphicStyles.primaryButtonColor,
              )
              : OptimizedTodoList(
                todos: simpleTodos,
                todoColors: provider.todoColors,
                onToggle: (id) => provider.toggleTodo(id),
                onDelete: (id) => provider.deleteTodo(id),
              ),

          // 구분선
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Divider(height: 2, color: Colors.grey),
          ),

          // 기간 있는 할 일 섹션
          _buildSectionHeader(
            title: '기간 있는 할 일',
            icon: Icons.event_note,
            color: NeumorphicStyles.cardColors[1],
            count: detailedTodos.length,
            iconColor: NeumorphicStyles.secondaryButtonColor,
          ),

          // 할 일 목록 또는 빈 상태 표시
          detailedTodos.isEmpty
              ? _buildEmptyState(
                icon: Icons.calendar_today,
                message: '기간 있는 할 일을 추가해보세요!',
                color: NeumorphicStyles.cardColors[1],
                iconColor: NeumorphicStyles.secondaryButtonColor,
              )
              : OptimizedTodoList(
                todos: detailedTodos,
                todoColors: provider.todoColors,
                onToggle: (id) => provider.toggleTodo(id),
                onDelete: (id) => provider.deleteTodo(id),
              ),

          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }

  // 섹션 헤더 위젯 (재사용 가능)
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 12, right: 20, top: 8),
      child: NeumorphicContainer(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: 12,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2), // withValues 대신 withOpacity 사용
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: NeumorphicStyles.textDark,
              ),
            ),
            const Spacer(),
            Text(
              '$count개',
              style: TextStyle(
                fontSize: 14,
                color: NeumorphicStyles.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 빈 상태 표시 위젯 (재사용 가능)
  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required Color color,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: NeumorphicContainer(
        height: 100,
        borderRadius: 16,
        color: NeumorphicStyles.backgroundColor.withOpacity(0.7), // withValues 대신 withOpacity 사용
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2), // withValues 대신 withOpacity 사용
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: NeumorphicStyles.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}