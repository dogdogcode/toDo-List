import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/calendar_screen.dart';
import 'screens/todo_list_screen.dart';
import 'screens/profile_screen.dart';

// 앱 테마 색상을 정의하는 클래스
class AppTheme {
  // 라이트 모드 팔레트
  static const Color mainColor = Color(0xFF4C92EA); // 메인 블루
  static const Color pointColor = Color(0xFF2E3A59); // 딥 네이비
  static const Color secondaryColor = Color(0xFFA7B8E4); // 라이트 블루
  static const Color backgroundColor = Color(0xFFF5F7FA); // 밝은 그레이
  static const Color textColor = Color(0xFF333333); // 진한 차콜

  // 다크 모드 팔레트
  static const Color darkMainColor = Color(0xFF728DCE); // 소프트 블루
  static const Color darkPointColor = Color(0xFFA7B8E4); // 라이트 블루
  static const Color darkSecondaryColor = Color(0xFF2E3A59); // 딥 네이비
  static const Color darkBackgroundColor = Color(0xFF1A1D26); // 다크 네이비 그레이
  static const Color darkSubBackgroundColor = Color(0xFF252A37); // 어두운 차콜 블루
  static const Color darkTextColor = Color(0xFFE3E6EF); // 밝은 그레이
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 오버레이 스타일 설정 (상태 표시줄, 내비게이션 바 등)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
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
        primaryColor: AppTheme.mainColor,
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppTheme.textColor),
          bodyMedium: TextStyle(color: AppTheme.textColor),
        ),
        colorScheme: ColorScheme.light(
          primary: AppTheme.mainColor,
          secondary: AppTheme.secondaryColor,
          surface: AppTheme.backgroundColor,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: AppTheme.darkMainColor,
        scaffoldBackgroundColor: AppTheme.darkBackgroundColor,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppTheme.darkTextColor),
          bodyMedium: TextStyle(color: AppTheme.darkTextColor),
        ),
        colorScheme: ColorScheme.dark(
          primary: AppTheme.darkMainColor,
          secondary: AppTheme.darkPointColor,
          surface: AppTheme.darkSubBackgroundColor,
        ),
      ),
      themeMode: ThemeMode.system, // 시스템 설정에 따라 테마 적용
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
            color: isDarkMode ? AppTheme.darkSubBackgroundColor : Colors.white,
            borderRadius: BorderRadius.circular(37.5), // 높이의 절반
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
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
                    isDarkMode,
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
                          color:
                              isDarkMode
                                  ? AppTheme.darkMainColor
                                  : AppTheme.mainColor,
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
    bool isDarkMode,
    double itemWidth,
  ) {
    final isSelected = _selectedIndex == index;

    // 선택된 아이템의 색상
    final Color activeColor =
        isDarkMode ? AppTheme.darkMainColor : AppTheme.mainColor;
    // 선택되지 않은 아이템의 색상
    final Color inactiveColor =
        isDarkMode ? AppTheme.darkTextColor.withOpacity(0.5) : Colors.grey;

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
                child: TweenAnimationBuilder(
                  tween: Tween<double>(
                    begin: isSelected ? 26 : 32,
                    end: isSelected ? 32 : 26,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, size, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        isSelected ? -4 : 0, // 이동 거리 줄임
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? activeColor : inactiveColor,
                        size: size,
                      ),
                    );
                  },
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
