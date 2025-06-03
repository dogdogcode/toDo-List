import 'dart:ui'; // Keep for BackdropFilter
import 'package:flutter/material.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Removed
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/todo_card.dart';
import 'add_todo_screen.dart';
import 'calendar_screen.dart'; // Added import for CalendarScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  // late AnimationController _scaleController; // Removed
  // late AnimationController _textController; // Removed
  // late Animation<double> _scaleAnimation; // Removed
  // late Animation<double> _borderRadiusAnimation; // Removed
  // late Animation<double> _textFadeAnimation; // Removed
  // late Animation<Offset> _textSlideAnimation; // Removed

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 스케일 애니메이션 컸트롤러 초기화 (아이폰 스타일)
    // _scaleController = AnimationController( // Removed
    //   duration: const Duration(milliseconds: 200),
    //   vsync: this,
    // );

    // 텍스트 애니메이션 컸트롤러
    // _textController = AnimationController( // Removed
    //   duration: const Duration(milliseconds: 800),
    //   vsync: this,
    // );

    // _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate( // Removed
    //   CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    // );

    // _borderRadiusAnimation = Tween<double>(begin: 0.0, end: 16.0).animate( // Removed
    //   CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    // );

    // _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate( // Removed
    //   CurvedAnimation(
    //     parent: _textController,
    //     curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    //   ),
    // );

    // _textSlideAnimation = Tween<Offset>( // Removed
    //   begin: const Offset(0, 0.3),
    //   end: Offset.zero,
    // ).animate(
    //   CurvedAnimation(
    //     parent: _textController,
    //     curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    //   ),
    // );

    // 앱 시작 시 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
      // _textController.forward(); // Removed: 텍스트 애니메이션 시작
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // _scaleController.dispose(); // Removed
    // _textController.dispose(); // Removed
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
        // child: AnimatedBuilder( // Removed AnimatedBuilder
        //   animation: Listenable.merge([
        //     _scaleAnimation,
        //     _borderRadiusAnimation,
        //   ]),
        //   builder: (context, child) {
        //     return Transform.scale( // Removed Transform.scale
        //       scale: _scaleAnimation.value,
        //       child: ClipRRect( // Removed ClipRRect
        //         borderRadius: BorderRadius.circular(
        //           _borderRadiusAnimation.value,
        //         ),
        //         child: Container( // Removed Container with conditional shadow
        //           decoration:
        //               _scaleAnimation.value < 1.0
        //                   ? BoxDecoration(
        //                     boxShadow: [
        //                       BoxShadow(
        //                         color: Colors.black.withOpacity(0.3),
        //                         blurRadius: 20,
        //                         spreadRadius: 2,
        //                         offset: const Offset(0, 10),
        //                       ),
        //                     ],
        //                   )
        //                   : null,
                  child: SafeArea( // SafeArea remains
                    child: PageView( // PageView remains
                      controller: _pageController, // controller remains
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      children: <Widget>[
                        // Home Screen Content
                        // Home Screen Content
                        Consumer<TodoProvider>( // Moved Consumer to wrap the content that needs provider
                          builder: (context, provider, child) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildAppBar(),
                                  _buildStatsCard(), // This already uses Consumer internally
                                  _buildSectionHeader("기간 없음", Icons.task_alt_outlined, provider.simpleTasks.length, theme.primaryColor),
                                  _buildSimpleTasksList(), // This uses Consumer internally
                                  _buildSectionHeader("마감일 있음", Icons.event_available_outlined, provider.deadlineTasks.length, theme.colorScheme.secondary),
                                  _buildDeadlineTasksList(), // This uses Consumer internally
                                ],
                              ),
                            );
                          },
                        ),
                        // Calendar Screen Content
                        const CalendarScreen(), // Replaced placeholder with CalendarScreen instance
                      ],
                    ),
                  ),
        //         ),
        //       ),
        //     );
        //   },
        // ),
      ),
      floatingActionButton: _buildFloatingActionButton(), // FAB remains
      bottomNavigationBar: ClipRect( // Added ClipRect for BackdropFilter
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: BottomNavigationBar(
            backgroundColor: theme.cardColor.withOpacity(isDark ? 0.1 : 0.5), // Semi-transparent background
            currentIndex: _currentIndex,
            onTap: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            selectedItemColor: theme.primaryColor,
            unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
            elevation: 0, // Remove default elevation, blur will handle depth
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // FadeTransition & SlideTransition removed
          Column(
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
          const Spacer(),
          // FadeTransition & ScaleTransition removed
          IconButton(
            onPressed: _showOptionsBottomSheet,
            icon: Icon(
              Icons.more_vert,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        // FadeTransition & SlideTransition removed
        return GlassCard(
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

  // Widget _buildTabBar() { // Removed this method as it's no longer used by the main PageView structure
  //   return Consumer<TodoProvider>(
  //     builder: (context, provider, child) {
  //       return FadeTransition(
  //         opacity: _textFadeAnimation,
  //         child: SlideTransition(
  //           position: Tween<Offset>(
  //             begin: const Offset(0, 0.7),
  //             end: Offset.zero,
  //           ).animate(
  //             CurvedAnimation(
  //               parent: _textController,
  //               curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
  //             ),
  //           ),
  //           child: Container(
  //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(20),
  //               child: BackdropFilter(
  //                 filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(20),
  //                     gradient: LinearGradient(
  //                       begin: Alignment.topLeft,
  //                       end: Alignment.bottomRight,
  //                       colors:
  //                           Theme.of(context).brightness == Brightness.dark
  //                               ? [
  //                                 Colors.white.withOpacity(0.08),
  //                                 Colors.white.withOpacity(0.03),
  //                               ]
  //                               : [
  //                                 Colors.white.withOpacity(0.6),
  //                                 Colors.white.withOpacity(0.3),
  //                               ],
  //                     ),
  //                     border: Border.all(
  //                       color:
  //                           Theme.of(context).brightness == Brightness.dark
  //                               ? Colors.white.withOpacity(0.1)
  //                               : Colors.white.withOpacity(0.3),
  //                       width: 1.0,
  //                     ),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.1),
  //                         blurRadius: 20,
  //                         spreadRadius: 1,
  //                         offset: const Offset(0, 10),
  //                       ),
  //                     ],
  //                   ),
  //                   // child: TabBar(  // The TabBar is removed
  //                   //   controller: _tabController,
  //                   //   indicator: BoxDecoration(
  //                   //     borderRadius: BorderRadius.circular(18),
  //                   //     gradient: LinearGradient(
  //                   //       colors: [
  //                   //         Theme.of(context).primaryColor,
  //                   //         Theme.of(context).primaryColor.withOpacity(0.8),
  //                   //       ],
  //                   //     ),
  //                   //     boxShadow: [
  //                   //       BoxShadow(
  //                   //         color: Theme.of(context).primaryColor.withOpacity(0.3),
  //                   //         blurRadius: 15,
  //                   //         spreadRadius: 1,
  //                   //         offset: const Offset(0, 5),
  //                   //       ),
  //                   //     ],
  //                   //   ),
  //                   //   labelColor: Colors.white,
  //                   //   unselectedLabelColor:
  //                   //       Theme.of(context).brightness == Brightness.dark
  //                   //           ? Colors.white70
  //                   //           : Colors.grey.shade600,
  //                   //   dividerColor: Colors.transparent,
  //                   //   indicatorSize: TabBarIndicatorSize.tab,
  //                   //   tabs: [
  //                   //     Tab(
  //                   //       child: Row(
  //                   //         mainAxisAlignment: MainAxisAlignment.center,
  //                   //         children: [
  //                   //           const Icon(Icons.task_alt, size: 20),
  //                   //           const SizedBox(width: 8),
  //                   //           Text('기간 없음 (${provider.simpleTasks.length})'),
  //                   //         ],
  //                   //       ),
  //                   //     ),
  //                   //     Tab(
  //                   //       child: Row(
  //                   //         mainAxisAlignment: MainAxisAlignment.center,
  //                   //         children: [
  //                   //           const Icon(Icons.schedule, size: 20),
  //                   //           const SizedBox(width: 8),
  //                   //           Text('기간 있음 (${provider.deadlineTasks.length})'),
  //                   //         ],
  //                   //       ),
  //                   //     ),
  //                   //   ],
  //                   // ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildSimpleTasksList() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.simpleTasks.isEmpty) {
          return _buildEmptyState('아직 할일이 없어요', '새로운 할일을 추가해보세요!');
        }

        // AnimationLimiter, AnimationConfiguration, SlideAnimation, FadeInAnimation removed
        return ListView.builder(
          shrinkWrap: true, // Added for SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // Added for SingleChildScrollView
          padding: const EdgeInsets.only(bottom: 16), // Adjusted padding
          itemCount: provider.simpleTasks.length,
          itemBuilder: (context, index) {
            final todo = provider.simpleTasks[index];
            return TodoCard(
              todo: todo,
              onToggle: () => provider.toggleTodoStatus(todo),
              onDelete: () => _showDeleteConfirmDialog(todo.id!),
            );
          },
        );
      },
    );
  }

  Widget _buildDeadlineTasksList() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          // For a shrinkWrapped list, returning a fixed small widget is better than Center
          return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
        }

        if (provider.deadlineTasks.isEmpty) {
          return _buildEmptyState('기간이 있는 할일이 없어요', '마감일이 있는 할일을 추가해보세요!');
        }

        // AnimationLimiter, AnimationConfiguration, SlideAnimation, FadeInAnimation removed
        return ListView.builder(
          shrinkWrap: true, // Added for SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // Added for SingleChildScrollView
          padding: const EdgeInsets.only(bottom: 80), // Keep padding for FAB space
          itemCount: provider.deadlineTasks.length,
          itemBuilder: (context, index) {
            final todo = provider.deadlineTasks[index];
            return TodoCard(
              todo: todo,
              onToggle: () => provider.toggleTodoStatus(todo),
              onDelete: () => _showDeleteConfirmDialog(todo.id!),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
    // ScaleTransition removed
    return Container(
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
    // _scaleController.forward(); // Removed

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTodoScreen(),
    ).then((_) {
      // _scaleController.reverse(); // Removed
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
