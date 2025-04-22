import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/calendar_screen.dart';
import 'screens/todo_list_screen.dart';
import 'screens/profile_screen.dart';
import 'utils/neumorphic_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 오버레이 스타일 설정 (상태 표시줄, 내비게이션 바 등)
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

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
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

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 처음 시작시 애니메이션 실행
    _animationController.forward();
  }

  @override
  void dispose() {
    // 리소스 해제
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // 네비게이션 바 크기 계산
    final navBarHeight = 75.0;
    final navBarWidth = screenWidth - 48.0; // 좌우 패딩 24씩 제외
    final itemWidth = navBarWidth / 3; // 3개 아이템 균등 배분

    return Scaffold(
      extendBody: true, // 본문이 네비게이션 바 뒤로 확장되도록 설정
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // 페이지 전환시 애니메이션 재시작
          _animationController.reset();
          _animationController.forward();
        },
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 20.0 + bottomPadding),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          height: navBarHeight,
          decoration: BoxDecoration(
            color: NeumorphicStyles.backgroundColor,
            borderRadius: BorderRadius.circular(37.5), // 높이의 절반
            boxShadow: [
              BoxShadow(
                color: NeumorphicStyles.darkShadow.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(4, 4),
              ),
              BoxShadow(
                color: NeumorphicStyles.lightShadow.withOpacity(0.7),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 탭 아이템들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_navItems.length, (index) {
                  return _buildNavItem(
                    _navItems[index]['icon'],
                    _navItems[index]['label'],
                    index,
                    itemWidth,
                  );
                }),
              ),

              // 인디케이터 - 정확한 위치 계산
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuint,
                // 정확한 중앙 위치 계산
                left: (itemWidth * _selectedIndex) + (itemWidth / 2) - 10,
                bottom: 8,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    // 애니메이션 계산
                    final value =
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.elasticOut,
                        ).value;

                    return Transform.scale(
                      scale: 0.5 + (value * 0.5),
                      child: Container(
                        width: 20,
                        height: 4,
                        decoration: BoxDecoration(
                          color: NeumorphicStyles.primaryButtonColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    double itemWidth,
  ) {
    final isSelected = _selectedIndex == index;

    // 선택된 아이템의 색상
    final Color activeColor = NeumorphicStyles.primaryButtonColor;
    // 선택되지 않은 아이템의 색상
    final Color inactiveColor = NeumorphicStyles.textLight;

    return SizedBox(
      width: itemWidth, // 동적으로 계산된 너비 사용
      child: InkWell(
        onTap: () {
          // 인디케이터 애니메이션 재시작
          _animationController.reset();
          _animationController.forward();

          setState(() {
            _selectedIndex = index;
          });

          // 페이지 전환
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuint,
          );
        },
        splashColor: Colors.transparent, // 물결 효과 제거
        highlightColor: Colors.transparent, // 하이라이트 효과 제거
        child: SizedBox(
          height: 75, // 컨테이너와 동일한 높이 설정
          child: Stack(
            clipBehavior: Clip.none, // 오버플로우 클리핑 방지
            alignment: Alignment.center,
            children: [
              // 아이콘 부분
              Positioned(
                top: 8, // 상단에 더 가깝게 위치
                child: Container(
                  width: 40,
                  height: 40,
                  decoration:
                      isSelected
                          ? BoxDecoration(
                            color: NeumorphicStyles.backgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: NeumorphicStyles.darkShadow.withOpacity(
                                  0.2,
                                ),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: const Offset(2, 2),
                              ),
                              BoxShadow(
                                color: NeumorphicStyles.lightShadow.withOpacity(
                                  0.5,
                                ),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: const Offset(-2, -2),
                              ),
                            ],
                          )
                          : null,
                  child: Icon(
                    icon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: 24,
                  ),
                ),
              ),

              // 텍스트 부분
              Positioned(
                bottom: 14, // 하단에 더 가깝게 위치
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected ? activeColor : inactiveColor,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13, // 폰트 크기 유지
                  ),
                  child: Text(label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
