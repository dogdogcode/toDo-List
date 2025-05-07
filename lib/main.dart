import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/calendar_screen.dart';
import 'screens/todo_list_screen.dart';
import 'screens/profile_screen.dart';
import 'utils/neumorphic_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: NeumorphicStyles.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo 리스트',
      theme: ThemeData(
        scaffoldBackgroundColor: NeumorphicStyles.backgroundColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: NeumorphicStyles.textDark),
          bodyMedium: TextStyle(color: NeumorphicStyles.textDark),
        ),
        colorScheme: const ColorScheme.light(
          primary: NeumorphicStyles.primaryButtonColor,
          secondary: NeumorphicStyles.secondaryButtonColor,
          surface: NeumorphicStyles.backgroundColor,
        ),
        appBarTheme: const AppBarTheme(
          color: NeumorphicStyles.backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: NeumorphicStyles.textDark),
          titleTextStyle: TextStyle(
            color: NeumorphicStyles.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // 버튼 테마 변경
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: NeumorphicStyles.primaryButtonColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0; // 기본값 "일정" 탭으로 설정

  // 네비게이션 아이템 정보
  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.calendar_today, 'label': '일정'},
    {'icon': Icons.check_box, 'label': '할 일'},
    {'icon': Icons.person, 'label': '프로필'},
  ];

  // initState에서 초기화할 변수들 선언
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _selectionAnimationController;

  final List<Widget> _screens = [
    const CalendarScreen(),
    const TodoListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // 페이지 컨트롤러 초기화
    _pageController = PageController(initialPage: _selectedIndex);

    // 기본 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 네비게이션 항목 선택 애니메이션 컨트롤러 초기화
    _selectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700), // 애니메이션 시간 증가
      vsync: this,
    );

    // 처음 시작시 애니메이션 실행
    _animationController.forward();
    _selectionAnimationController.forward();
  }

  @override
  void dispose() {
    // 리소스 해제
    _pageController.dispose();
    _animationController.dispose();
    _selectionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight = 95.0;
    final navBarWidth = screenWidth - 48.0;
    final itemWidth = navBarWidth / 3;

    return Scaffold(
      extendBody: true, // 본문이 네비게이션 바 뒤로 확장되도록 설정
      body: Stack(
        children: [
          // 메인 컨텐츠
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _animationController.reset();
              _animationController.forward();
              _selectionAnimationController.reset();
              _selectionAnimationController.forward();
            },
            children: _screens,
          ),

          // 네비게이션 바 - 터치 영역 제한
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 10,
            child: Center(
              child: Container(
                width: navBarWidth,
                height: navBarHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: NeumorphicStyles.backgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 38,
                      ), // 변경: withOpacity(0.15) -> withValues(alpha: 38)
                      offset: const Offset(0, 4),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(
                        alpha: 179,
                      ), // 변경: withOpacity(0.7) -> withValues(alpha: 179)
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_navItems.length, (index) {
                    return SizedBox(
                      width: itemWidth,
                      child: Center(
                        child: _buildNavItem(
                          _navItems[index]['icon'],
                          _navItems[index]['label'],
                          index,
                          itemWidth * 0.8, // 터치 영역을 아이템 너비의 80%로 제한
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, double width) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;
        return SizedBox(
          width: width,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque, // 터치 영역을 시각적 영역으로 제한
            onTapDown: (_) => setState(() => isPressed = true),
            onTapUp: (_) {
              setState(() => isPressed = false);
              this.setState(() => _selectedIndex = index);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuint,
              );
            },
            onTapCancel: () => setState(() => isPressed = false),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘 버튼
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isPressed || _selectedIndex == index
                            ? NeumorphicStyles.backgroundColor.withValues(
                              alpha: 204,
                            )
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow:
                        isPressed || _selectedIndex == index
                            ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                offset: const Offset(-2, -2),
                                blurRadius: 4,
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(
                    icon,
                    color:
                        _selectedIndex == index
                            ? NeumorphicStyles.primaryButtonColor
                            : NeumorphicStyles.textLight,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                        _selectedIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                    color:
                        _selectedIndex == index
                            ? NeumorphicStyles.primaryButtonColor
                            : NeumorphicStyles.textLight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
