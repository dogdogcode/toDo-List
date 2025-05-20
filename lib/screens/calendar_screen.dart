import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/neumorphic_styles.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../utils/constants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 상수값 사용
  final Map<DateTime, List<String>> _holidays = AppConstants.koreanHolidays;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Todo> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Provider를 통한 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TodoProvider>(context, listen: false);
      provider.loadTodos();

      // 선택된 날짜에 해당하는 이벤트 로드
      setState(() {
        _selectedEvents = provider.getEventsForDay(_selectedDay!);
      });
    });
  }

  // 공휴일 확인 함수
  List<String> _getHolidaysForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _holidays[normalizedDay] ?? [];
  }

  // 이벤트와 공휴일을 함께 표시하기 위한 함수
  List<dynamic> _getEventsAndHolidaysForDay(
    DateTime day,
    TodoProvider provider,
  ) {
    final List<dynamic> result = [];
    result.addAll(provider.getEventsForDay(day));
    final holidays = _getHolidaysForDay(day);
    for (var holiday in holidays) {
      result.add(holiday);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final bottomNavHeight = 100.0;  // 네비게이션 바 하단 여백 공간
    
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return Scaffold(
          backgroundColor: NeumorphicStyles.backgroundColor,
          body: Column(
            children: [
              // 헤더
              _buildHeader(),

              // 캘린더 - 메모이제이션으로 불필요한 리빌드 방지
              _buildCalendar(todoProvider),

              // 선택한 날짜의 할 일 목록 - 하단 여백 적용
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomNavHeight),
                  child: _buildEventList(todoProvider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 이하 UI 영역은 크게 변경 없이 Provider에서 데이터를 가져오도록 수정

  Widget _buildHeader() {
    // 기존 코드 유지
    // ...existing code...
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          // 타이틀 및 버튼 행
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 타이틀 문구 개선
              Row(
                children: [
                  // 아이콘 컨테이너 개선
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: NeumorphicStyles.secondaryButtonColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          offset: const Offset(-1, -1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '일정 관리',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicStyles.textDark,
                        ),
                      ),
                      Text(
                        '${_focusedDay.year}년 ${_focusedDay.month}월',
                        style: TextStyle(
                          fontSize: 14,
                          color: NeumorphicStyles.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // "오늘로 이동" 버튼 개선
              NeumorphicButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                    _selectedEvents = Provider.of<TodoProvider>(
                      context,
                      listen: false,
                    ).getEventsForDay(_selectedDay!);
                  });
                },
                width: 120,
                height: 40,
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: NeumorphicStyles.secondaryButtonColor.withOpacity(0.1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.today,
                      color: NeumorphicStyles.secondaryButtonColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '오늘',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NeumorphicStyles.secondaryButtonColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 현재 날짜 표시
          const SizedBox(height: 16),
          NeumorphicContainer(
            height: 40,
            color: NeumorphicStyles.backgroundColor,
            borderRadius: 12,
            intensity: 0.1,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  color: NeumorphicStyles.secondaryButtonColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDay != null
                      ? '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일'
                      : '날짜를 선택해주세요',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NeumorphicStyles.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(TodoProvider provider) {
    // 기존 코드에서 Provider 사용하도록 변경
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: NeumorphicContainer(
        width: double.infinity,
        height: 360, // 높이 최적화
        intensity: 0.07,
        borderRadius: 20, // 더 둥근 모서리
        padding: const EdgeInsets.all(8),
        color: NeumorphicStyles.backgroundColor,
        child: TableCalendar(
          firstDay: DateTime.utc(2021, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: (day) => _getEventsAndHolidaysForDay(day, provider),
          // 공휴일 스타일 적용
          holidayPredicate: (day) {
            return _getHolidaysForDay(day).isNotEmpty;
          },
          // 기존 스타일 코드 그대로 유지
          // ...existing code...
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedEvents = provider.getEventsForDay(selectedDay);
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay; // 괄호 오류 수정
            });
          },
          // 기존 캘린더 빌더 코드 유지
          // ...existing code...
        ),
      ),
    );
  }

  Widget _buildEventList(TodoProvider provider) {
    // 공휴일 확인
    final holidays = _getHolidaysForDay(_selectedDay!);
    final bool hasHoliday = holidays.isNotEmpty;

    if (_selectedEvents.isEmpty && !hasHoliday) {
      // 빈 상태 표시
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: const Color.fromRGBO(150, 150, 150, 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '${_selectedDay?.month}월 ${_selectedDay?.day}일에 할 일이 없습니다',
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 이벤트 목록 표시 - 기존 코드 유지
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 공휴일 표시
        if (hasHoliday)
          // ...existing code...
          // 할 일 목록
          if (_selectedEvents.isEmpty)
            SizedBox.shrink()
          else
            ...List.generate(_selectedEvents.length, (index) {
              final todo = _selectedEvents[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEventCard(todo, provider),
              );
            }),
      ],
    );
  }

  Widget _buildEventCard(Todo todo, TodoProvider provider) {
    // 태그별 색상 배열 - const로 정의하여 재생성 방지
    const tagColors = [
      Color(0xFF3D5AFE), // Primary Button Color
      Color(0xFF651FFF), // Secondary Button Color
      Color(0xFF00C853), // Green
      Color(0xFFAA00FF), // Purple
      Color(0xFFFF9100), // Orange
    ];

    // 기존 이벤트 카드 UI 유지
    // ...existing code...
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: NeumorphicContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        intensity: 0.1,
        borderRadius: 16,
        color:
            todo.completed
                ? NeumorphicStyles.backgroundColor.withOpacity(0.7)
                : NeumorphicStyles.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 헤더 - 제목과 체크박스
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 체크박스
                NeumorphicCheckbox(
                  value: todo.completed,
                  onChanged: (value) async {
                    await provider.toggleTodo(todo.id);
                    setState(() {
                      _selectedEvents = provider.getEventsForDay(_selectedDay!);
                    });
                  },
                  color: NeumorphicStyles.backgroundColor,
                ),
                const SizedBox(width: 12),
                // 제목
                Expanded(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          todo.completed
                              ? NeumorphicStyles.textLight
                              : NeumorphicStyles.textDark,
                      decoration:
                          todo.completed ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 삭제 버튼
                NeumorphicButton(
                  onPressed: () async {
                    await provider.deleteTodo(todo.id);
                    setState(() {
                      _selectedEvents = provider.getEventsForDay(_selectedDay!);
                    });
                  },
                  width: 32,
                  height: 32,
                  padding: EdgeInsets.zero,
                  borderRadius: 16,
                  color: NeumorphicStyles.backgroundColor,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),

            // 메모 (있을 경우)
            if (todo.memo != null && todo.memo!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                todo.memo!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // 태그 섹션
            if (todo.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    todo.tags.map((tag) {
                      final index = todo.tags.indexOf(tag);
                      final color = tagColors[index % tagColors.length];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(
                            color.r.toInt(), // red -> r
                            color.g.toInt(), // green -> g
                            color.b.toInt(), // blue -> b
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color.fromRGBO(
                              color.r.toInt(), // red -> r
                              color.g.toInt(), // green -> g
                              color.b.toInt(), // blue -> b
                              0.3,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
