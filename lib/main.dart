import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/todo_list_screen.dart';
import 'screens/profile_screen.dart';
import 'utils/neumorphic_styles.dart';
import 'providers/todo_provider.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 최적화
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: NeumorphicStyles.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Provider를 활용한 상태 관리 설정
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TodoProvider())],
      child: const TodoApp(),
    ),
  );
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

  // 각 화면을 직접 생성하지 않고 필요할 때 생성하기 위한 게으른 초기화
  late final List<Widget> _screens = [
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
      duration: AppConstants.animationDuration,
      vsync: this,
    );

    // 네비게이션 항목 선택 애니메이션 컨트롤러 초기화
    _selectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bottomPadding = mediaQuery.padding.bottom;
    final topPadding = mediaQuery.padding.top;
    
    // 네비게이션 바 크기 및 위치 계산
    final navBarHeight = AppConstants.bottomNavHeight;
    final navBarWidth = screenWidth - 48.0;
    final itemWidth = navBarWidth / 3;
    
    // 콘텐츠 영역에 네비게이션 바 영역을 고려한 패딩 추가
    final contentBottomPadding = navBarHeight + bottomPadding + 20.0;

    return Scaffold(
      extendBody: true, // 본문이 네비게이션 바 뒤로 확장되도록 설정
      body: SafeArea(
        // 시스템 UI 영역을 안전하게 피함
        bottom: false, // 하단은 SafeArea에서 제외 (navBar가 별도로 관리)
        child: Stack(
          children: [
            // 메인 컨텐츠
            Padding(
              padding: EdgeInsets.only(
                bottom: contentBottomPadding,
              ),
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(), // 스크롤 물리학 개선
                itemCount: _screens.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  _animationController.reset();
                  _animationController.forward();
                  _selectionAnimationController.reset();
                  _selectionAnimationController.forward();
                },
                itemBuilder: (context, index) {
                  // 충돌 방지를 위해 SafeArea 적용
                  return SafeArea(
                    bottom: false,
                    child: _screens[index],
                  );
                },
              ),
            ),

            // 네비게이션 바 - 바닥에 고정되고 안정적인 위치 유지
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomPadding + 10, // 시스템 탐색 영역 고려
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
                    color: Colors.black.withOpacity(0.15), // 0.15 opacity
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                    ),
                    BoxShadow(
                    color: Colors.white.withOpacity(0.7), // 0.7 opacity
                    offset: const Offset(0, -2),
                    blurRadius: 6,
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
                duration: AppConstants.animationDuration,
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
                    color: isPressed || _selectedIndex == index
                            ? NeumorphicStyles.backgroundColor.withOpacity(0.8) // 0.8 opacity
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow:
                        isPressed || _selectedIndex == index
                            ? [
                                BoxShadow(
                                color: Colors.black.withOpacity(0.1), // 0.1 opacity
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5), // 0.5 opacity
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