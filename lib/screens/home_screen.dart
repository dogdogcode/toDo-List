import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/todo_card.dart';
import 'add_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _scaleController;
  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderRadiusAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 스케일 애니메이션 컸트롤러 초기화 (아이폰 스타일)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // 텍스트 애니메이션 컸트롤러
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _borderRadiusAnimation = Tween<double>(begin: 0.0, end: 16.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    // 앱 시작 시 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
      _textController.forward(); // 텍스트 애니메이션 시작
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scaleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      const Color(0xFF0F0C29).withOpacity(0.85),
                      const Color(0xFF302B63).withOpacity(0.8),
                      const Color(0xFF24243E).withOpacity(0.85),
                    ]
                    : [
                      const Color(0xFFE0C3FC).withOpacity(0.8),
                      const Color(0xFF8EC5FC).withOpacity(0.75),
                      const Color(0xFFFFE0F7).withOpacity(0.8),
                    ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _borderRadiusAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  _borderRadiusAnimation.value,
                ),
                child: Container(
                  decoration:
                      _scaleAnimation.value < 1.0
                          ? BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          )
                          : null,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // 커스텀 앱바
                        _buildAppBar(),

                        // 통계 카드
                        _buildStatsCard(),

                        // 탭바
                        _buildTabBar(),

                        // 탭 뷰
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildSimpleTasksList(),
                              _buildDeadlineTasksList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          FadeTransition(
            opacity: _textFadeAnimation,
            child: SlideTransition(
              position: _textSlideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요! 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '오늘도 화이팅하세요!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          FadeTransition(
            opacity: _textFadeAnimation,
            child: ScaleTransition(
              scale: _textFadeAnimation,
              child: IconButton(
                onPressed: _showOptionsBottomSheet,
                icon: Icon(
                  Icons.more_vert,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        return FadeTransition(
          opacity: _textFadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _textController,
                curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
              ),
            ),
            child: GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildStatItem(
                    '전체',
                    provider.totalTasks,
                    Icons.list_alt,
                    Colors.blue,
                    0,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    '완료',
                    provider.completedTasks,
                    Icons.check_circle,
                    Colors.green,
                    1,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    '대기',
                    provider.pendingTasks,
                    Icons.pending,
                    Colors.orange,
                    2,
                  ),
                  if (provider.overdueTasks > 0) ...[
                    const SizedBox(width: 16),
                    _buildStatItem(
                      '초과',
                      provider.overdueTasks,
                      Icons.warning,
                      Colors.red,
                      3,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    int count,
    IconData icon,
    Color color,
    int index,
  ) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 600 + (index * 100)),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<int>(
                  duration: Duration(milliseconds: 800 + (index * 100)),
                  tween: IntTween(begin: 0, end: count),
                  builder: (context, value, child) {
                    return Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    );
                  },
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        return FadeTransition(
          opacity: _textFadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.7),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _textController,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            Theme.of(context).brightness == Brightness.dark
                                ? [
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.03),
                                ]
                                : [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.3),
                                ],
                      ),
                      border: Border.all(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.3),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey.shade600,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.task_alt, size: 20),
                              const SizedBox(width: 8),
                              Text('기간 없음 (${provider.simpleTasks.length})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.schedule, size: 20),
                              const SizedBox(width: 8),
                              Text('기간 있음 (${provider.deadlineTasks.length})'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleTasksList() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.simpleTasks.isEmpty) {
          return _buildEmptyState('아직 할일이 없어요', '새로운 할일을 추가해보세요!');
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: provider.simpleTasks.length,
            itemBuilder: (context, index) {
              final todo = provider.simpleTasks[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: TodoCard(
                      todo: todo,
                      onToggle: () => provider.toggleTodoStatus(todo),
                      onDelete: () => _showDeleteConfirmDialog(todo.id!),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDeadlineTasksList() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.deadlineTasks.isEmpty) {
          return _buildEmptyState('기간이 있는 할일이 없어요', '마감일이 있는 할일을 추가해보세요!');
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: provider.deadlineTasks.length,
            itemBuilder: (context, index) {
              final todo = provider.deadlineTasks[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: TodoCard(
                      todo: todo,
                      onToggle: () => provider.toggleTodoStatus(todo),
                      onDelete: () => _showDeleteConfirmDialog(todo.id!),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white38
                    : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white38
                      : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _textController,
          curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddTodoScreen,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            '할일 추가',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showAddTodoScreen() {
    // 배경 축소 애니메이션 시작
    _scaleController.forward();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTodoScreen(),
    ).then((_) {
      // 배경 원래 크기로 복원
      _scaleController.reverse();
      // 화면이 닫힐 때 데이터 새로고침
      context.read<TodoProvider>().loadTodos();
    });
  }

  void _showDeleteConfirmDialog(int todoId) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('할일 삭제'),
            content: const Text('이 할일을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<TodoProvider>().deleteTodo(todoId);
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          Theme.of(context).brightness == Brightness.dark
                              ? [
                                Colors.white.withOpacity(0.08),
                                Colors.white.withOpacity(0.03),
                              ]
                              : [
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.3),
                              ],
                    ),
                    border: Border.all(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 핸들 바
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.delete_sweep,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey.shade700,
                        ),
                        title: Text(
                          '완료된 할일 모두 삭제',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteCompletedConfirmDialog();
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.refresh,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey.shade700,
                        ),
                        title: Text(
                          '새로고침',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context.read<TodoProvider>().loadTodos();
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void _showDeleteCompletedConfirmDialog() {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('완료된 할일 삭제'),
            content: const Text('완료된 모든 할일을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<TodoProvider>().deleteCompletedTodos();
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
