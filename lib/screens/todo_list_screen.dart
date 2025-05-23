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
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  final double _expandedAppBarHeight = 200.0; // 확장 시 헤더 높이 조정
  final double _collapsedAppBarHeight = 90.0; // 축소 시 헤더 높이 조정

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).loadTodos();
    });
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // 스크롤 위치에 따라 헤더 축소/확장 상태 변경 (애니메이션 효과 개선)
    final offset = _scrollController.offset;
    if (offset > 70 && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    } else if (offset <= 70 && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addSimpleTodo() async {
    if (_textController.text.isNotEmpty) {
      await Provider.of<TodoProvider>(
        context,
        listen: false,
      ).addSimpleTodo(_textController.text);
      _textController.clear();
      // 키보드 숨기기
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return Scaffold(
          backgroundColor: NeumorphicStyles.backgroundColor.withOpacity(
            0.98,
          ), // 배경 반투명
          body: SafeArea(
            // SafeArea 추가하여 시스템 UI와 겹치지 않도록 함
            child: Column(
              children: [
                _buildAnimatedHeader(),
                Expanded(
                  child:
                      todoProvider.isLoading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: NeumorphicStyles.primaryButtonColor
                                  .withOpacity(0.8),
                            ),
                          )
                          : _buildCombinedListView(todoProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250), // 애니메이션 속도 조정
      curve: Curves.easeOut, // 애니메이션 커브 변경
      height: _isCollapsed ? _collapsedAppBarHeight : _expandedAppBarHeight,
      decoration: BoxDecoration(
        // 헤더 배경에 미묘한 그림자 추가
        color: NeumorphicStyles.backgroundColor.withOpacity(0.95),
        boxShadow:
            _isCollapsed
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: _isCollapsed ? _buildCollapsedHeader() : _buildExpandedHeader(),
    );
  }

  Widget _buildCollapsedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: NeumorphicStyles.primaryButtonColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.checklist_rtl_rounded, // 아이콘 변경
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '나의 할 일', // 타이틀 변경
                style: TextStyle(
                  fontSize: 22, // 폰트 크기 조정
                  fontWeight: FontWeight.bold,
                  color: NeumorphicStyles.textDark,
                ),
              ),
            ],
          ),
          // 축소 시에는 추가 버튼 숨김 또는 다른 UI로 대체 가능
        ],
      ),
    );
  }

  Widget _buildExpandedHeader() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16), // 상단 여백 추가
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40, // 아이콘 컨테이너 크기 조정
                          height: 40,
                          decoration: BoxDecoration(
                            color: NeumorphicStyles.primaryButtonColor
                                .withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.checklist_rtl_rounded, // 아이콘 변경
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '나의 할 일', // 타이틀 변경
                          style: TextStyle(
                            fontSize: 26, // 폰트 크기 조정
                            fontWeight: FontWeight.bold,
                            color: NeumorphicStyles.textDark,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 52,
                        top: 2,
                      ), // 설명 텍스트 위치 조정
                      child: Text(
                        '오늘의 작업을 효율적으로 관리하세요.', // 설명 문구 변경
                        style: TextStyle(
                          fontSize: 14,
                          color: NeumorphicStyles.textLight.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTodoInputSection(),
        ],
      ),
    );
  }

  Widget _buildTodoInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          NeumorphicContainer(
            height: 58, // 높이 조정
            borderRadius: 16,
            color: NeumorphicStyles.backgroundColor.withOpacity(0.9), // 반투명 배경
            intensity: 0.1, // 뉴모피즘 강도 약하게
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ), // 내부 패딩 조정
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '빠르게 할 일 추가...', // 힌트 텍스트 변경
                      hintStyle: TextStyle(
                        color: NeumorphicStyles.textLight.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: NeumorphicStyles.textDark,
                    ), // 텍스트 스타일 추가
                    onSubmitted: (_) => _addSimpleTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                NeumorphicButton(
                  onPressed: _addSimpleTodo,
                  width: 44, // 버튼 크기 조정
                  height: 44,
                  borderRadius: 14,
                  color: NeumorphicStyles.primaryButtonColor.withOpacity(0.85),
                  child: const Center(
                    child: Icon(
                      Icons.add_task_rounded, // 아이콘 변경
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NeumorphicButton(
            onPressed: () => _showDetailedTodoInput(context),
            width: double.infinity,
            height: 50, // 높이 조정
            borderRadius: 14,
            color: NeumorphicStyles.backgroundColor.withOpacity(0.9), // 반투명 배경
            intensity: 0.08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_calendar_outlined, // 아이콘 변경
                  color: NeumorphicStyles.secondaryButtonColor.withOpacity(0.9),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  '상세 할 일 추가하기', // 버튼 텍스트 변경
                  style: TextStyle(
                    color: NeumorphicStyles.textDark.withOpacity(0.9),
                    fontWeight: FontWeight.w600, // 굵기 조정
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

  void _showDetailedTodoInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 모달 배경 투명하게
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
            ), // 상단 여백 추가
            child: DetailedTodoInput(
              onSave: (todo) async {
                await Provider.of<TodoProvider>(
                  context,
                  listen: false,
                ).addDetailedTodo(todo);
              },
            ),
          ),
    );
  }

  Widget _buildCombinedListView(TodoProvider provider) {
    final simpleTodos = provider.simpleTodos;
    final detailedTodos = provider.detailedTodos;
    final bottomNavHeight = 110.0;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottomNavHeight, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (simpleTodos.isNotEmpty || detailedTodos.isNotEmpty) ...[
            // 기간 없는 할 일 섹션
            if (simpleTodos.isNotEmpty)
              _buildSectionHeader(
                title: '간편 할 일',
                icon: Icons.quickreply_rounded,
                color: NeumorphicStyles.cardColors[0].withOpacity(0.8),
                count: simpleTodos.length,
                iconColor: NeumorphicStyles.primaryButtonColor.withOpacity(0.9),
              ),
            if (simpleTodos.isNotEmpty)
              OptimizedTodoList(
                todos: simpleTodos,
                todoColors: provider.todoColors,
                onToggle: (id) => provider.toggleTodo(id),
                onDelete: (id) => provider.deleteTodo(id),
              ),
            // 상세 할 일이 있고, 간편 할 일이 없을 때만 빈 상태 메시지 표시
            if (detailedTodos.isNotEmpty && simpleTodos.isEmpty)
              _buildEmptyState(
                icon: Icons.playlist_add_check_rounded, // 아이콘 수정
                message: '오늘 할 일을 추가해보세요!',
                color: NeumorphicStyles.cardColors[0].withOpacity(0.7),
                iconColor: NeumorphicStyles.primaryButtonColor.withOpacity(0.8),
              ),

            // 두 목록 사이에 간격 또는 구분선 추가
            if (simpleTodos.isNotEmpty && detailedTodos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: NeumorphicStyles.textLight.withOpacity(0.15),
                ), // Divider 색상 변경
              ),

            // 기간 있는 할 일 섹션
            if (detailedTodos.isNotEmpty)
              _buildSectionHeader(
                title: '상세 계획',
                icon: Icons.event_note_rounded,
                color: NeumorphicStyles.cardColors[1].withOpacity(0.8),
                count: detailedTodos.length,
                iconColor: NeumorphicStyles.secondaryButtonColor.withOpacity(
                  0.9,
                ),
              ),
            if (detailedTodos.isNotEmpty)
              OptimizedTodoList(
                todos: detailedTodos,
                todoColors: provider.todoColors,
                onToggle: (id) => provider.toggleTodo(id),
                onDelete: (id) => provider.deleteTodo(id),
              ),
          ] else ...[
            // 모든 할 일이 없을 때 중앙에 표시할 빈 상태 위젯
            _buildEmptyState(
              icon: Icons.all_inbox_rounded,
              message: '모든 할 일을 완료했거나, 아직 할 일이 없어요!',
              color: Colors.grey.withOpacity(0.1),
              iconColor: Colors.grey.withOpacity(0.6),
              isCentered: true,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color, // NeumorphicContainer의 배경색으로 사용될 색상
    required int count,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20, top: 12),
      child: NeumorphicContainer(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: 14,
        color: NeumorphicStyles.backgroundColor.withOpacity(
          0.9,
        ), // 컨테이너 자체의 배경색
        intensity: 0.05, // 뉴모피즘 강도 설정
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.25), // 아이콘 배경색 (전달받은 color 사용)
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: NeumorphicStyles.textDark.withOpacity(0.9),
              ),
            ),
            const Spacer(),
            Text(
              '$count개',
              style: TextStyle(
                fontSize: 14,
                color: NeumorphicStyles.textLight.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required Color color,
    required Color iconColor,
    bool isCentered = false, // 중앙 정렬 플래그 추가
  }) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10), // 아이콘 배경 패딩 조정
          decoration: BoxDecoration(
            color: color.withOpacity(0.25), // 아이콘 배경 투명도 조정
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: iconColor), // 아이콘 크기 조정
        ),
        const SizedBox(height: 14),
        Text(
          message,
          textAlign: TextAlign.center, // 텍스트 중앙 정렬
          style: TextStyle(
            fontSize: 15, // 폰트 크기 조정
            color: NeumorphicStyles.textLight.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (isCentered) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5, // 화면의 절반 높이
        child: Center(child: content),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 20,
      ), // 패딩 조정
      child: NeumorphicContainer(
        height: 120, // 높이 조정
        borderRadius: 16,
        color: NeumorphicStyles.backgroundColor.withOpacity(0.85), // 반투명 배경
        intensity: 0.05,
        child: Center(child: content),
      ),
    );
  }
}
