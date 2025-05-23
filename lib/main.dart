import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart'; // 추가된 임포트
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/todo_list_screen.dart';
import 'utils/constants.dart';
import 'utils/neumorphic_styles.dart';

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

  await initializeDateFormatting('ko_KR', null); // 날짜 포맷 초기화 추가

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
    final bottomPadding = mediaQuery.padding.bottom;

    // 네비게이션 바 크기 및 위치 계산
    const navBarHeight = AppConstants.bottomNavHeight;
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
              padding: EdgeInsets.only(bottom: contentBottomPadding),
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
                  return SafeArea(bottom: false, child: _screens[index]);
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
                    color: NeumorphicStyles.backgroundColor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 6),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        offset: const Offset(0, -3),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_navItems.length, (index) {
                      return Expanded(
                        // SizedBox를 Expanded로 변경
                        child: GestureDetector(
                          onTap: () => _onItemTapped(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ), // 패딩 조정
                            decoration: BoxDecoration(
                              color:
                                  _selectedIndex == index
                                      ? NeumorphicStyles.primaryButtonColor
                                          .withOpacity(
                                            // primaryColor를 primaryButtonColor로 변경
                                            0.15,
                                          ) // 선택된 탭 배경색 변경
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                16,
                              ), // 둥근 모서리 추가
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _navItems[index]['icon'] as IconData,
                                  color:
                                      _selectedIndex == index
                                          ? NeumorphicStyles
                                              .primaryButtonColor // primaryColor를 primaryButtonColor로 변경
                                          : NeumorphicStyles.textLight
                                              .withOpacity(0.7), // 아이콘 색상 변경
                                  size: 26, // 아이콘 크기 조정
                                ),
                                const SizedBox(height: 4), // 아이콘과 텍스트 간격 조정
                                Text(
                                  _navItems[index]['label'] as String,
                                  style: TextStyle(
                                    color:
                                        _selectedIndex == index
                                            ? NeumorphicStyles
                                                .primaryButtonColor // primaryColor를 primaryButtonColor로 변경
                                            : NeumorphicStyles.textLight
                                                .withOpacity(0.7), // 텍스트 색상 변경
                                    fontSize: 11, // 폰트 크기 조정
                                    fontWeight:
                                        _selectedIndex == index
                                            ? FontWeight.bold
                                            : FontWeight.normal, // 선택된 탭 폰트 강조
                                  ),
                                ),
                              ],
                            ),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: AppConstants.animationDuration,
      curve: Curves.easeOutQuint,
    );
  }
}
