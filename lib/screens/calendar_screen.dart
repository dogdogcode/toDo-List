import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';
import '../utils/neumorphic_styles.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 상수값 사용
  final Map<DateTime, List<String>> _holidays = AppConstants.koreanHolidays;
  CalendarFormat _calendarFormat = CalendarFormat.month; // final 제거
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
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return Scaffold(
          backgroundColor: NeumorphicStyles.backgroundColor.withOpacity(
            0.98,
          ), // 배경 반투명 적용
          body: SafeArea(
            // SafeArea 추가
            child: Column(
              children: [
                // 헤더
                _buildHeader(),

                // 캘린더
                _buildCalendar(todoProvider),

                // 선택한 날짜의 할 일 목록
                Expanded(child: _buildEventList(todoProvider)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 12,
      ), // 패딩 조정
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  NeumorphicContainer(
                    // 아이콘 컨테이너 개선
                    width: 42,
                    height: 42,
                    borderRadius: 14,
                    color: NeumorphicStyles.secondaryButtonColor.withOpacity(
                      0.85,
                    ),
                    // intensity: 0.1, // NeumorphicContainer는 intensity를 받음
                    child: const Icon(
                      Icons.calendar_month_outlined, // 아이콘 변경
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
                          fontSize: 24, // 폰트 크기 조정
                          fontWeight: FontWeight.bold,
                          color: NeumorphicStyles.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_focusedDay.year}년 ${_focusedDay.month}월',
                        style: TextStyle(
                          fontSize: 14,
                          color: NeumorphicStyles.textLight.withOpacity(
                            0.9,
                          ), // 투명도 적용
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                width: 90, // 너비 조정
                height: 42, // 높이 조정
                borderRadius: 14, // 테두리 반경 조정
                padding: EdgeInsets.zero, // 내부 패딩 제거
                color: NeumorphicStyles.backgroundColor.withOpacity(
                  0.9,
                ), // 배경색 변경
                // intensity: 0.08, // NeumorphicButton은 intensity를 직접 받지 않음
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.today_outlined, // 아이콘 변경
                      color: NeumorphicStyles.secondaryButtonColor.withOpacity(
                        0.9,
                      ),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '오늘',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NeumorphicStyles.textDark.withOpacity(
                          0.9,
                        ), // 텍스트 색상 변경
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NeumorphicContainer(
            height: 42, // 높이 조정
            color: NeumorphicStyles.backgroundColor.withOpacity(0.9), // 배경색 변경
            borderRadius: 14, // 테두리 반경 조정
            // intensity: 0.08, // NeumorphicContainer는 intensity를 받음
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available_outlined, // 아이콘 변경
                  color: NeumorphicStyles.secondaryButtonColor.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  _selectedDay != null
                      ? '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일'
                      : '날짜를 선택해주세요',
                  style: TextStyle(
                    fontSize: 15, // 폰트 크기 조정
                    fontWeight: FontWeight.w600, // 굵기 조정
                    color: NeumorphicStyles.textDark.withOpacity(0.9),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: NeumorphicStyles.getNeumorphicElevated(
          color: NeumorphicStyles.backgroundColor,
          radius: 20,
          intensity: 0.08,
          opacity: 0.93,
        ),
        padding: const EdgeInsets.all(16),
        child: TableCalendar(
          locale: 'ko_KR', // 한글 로케일 설정
          firstDay: DateTime.utc(2020, 1, 1), // 범위 시작일 조정
          lastDay: DateTime.utc(2035, 12, 31), // 범위 종료일 조정
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: (day) => _getEventsAndHolidaysForDay(day, provider),
          holidayPredicate: (day) {
            return _getHolidaysForDay(day).isNotEmpty;
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // Keep focusedDay in sync
              _selectedEvents = provider.getEventsForDay(selectedDay);
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            // 달력 포맷 변경 UI 추가
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          calendarBuilders: CalendarBuilders(
            // 뉴모피즘 스타일 적용
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              return Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NeumorphicStyles.primaryButtonColor.withOpacity(0.7),
                  ),
                  width: 6,
                  height: 6,
                ),
              );
            },
            todayBuilder: (context, day, focusedDay) {
              return Center(
                child: NeumorphicContainer(
                  width: 36,
                  height: 36,
                  borderRadius: 18,
                  intensity: 0.1,
                  color: NeumorphicStyles.secondaryButtonColor.withOpacity(0.2),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: NeumorphicStyles.secondaryButtonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              return Center(
                child: NeumorphicContainer(
                  width: 36,
                  height: 36,
                  borderRadius: 18,
                  intensity: 0.15,
                  color: NeumorphicStyles.primaryButtonColor.withOpacity(0.9),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
            holidayBuilder: (context, day, focusedDay) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: Colors.redAccent.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
            defaultBuilder: (context, day, focusedDay) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: NeumorphicStyles.textDark.withOpacity(0.8),
                  ),
                ),
              );
            },
            outsideBuilder: (context, day, focusedDay) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: NeumorphicStyles.textLight.withOpacity(0.4),
                  ),
                ),
              );
            },
          ),
          headerStyle: HeaderStyle(
            // 헤더 스타일 변경
            formatButtonVisible: true, // 월/주 포맷 변경 버튼 표시
            formatButtonShowsNext: false,
            formatButtonTextStyle: TextStyle(
              color: NeumorphicStyles.textDark.withOpacity(0.8),
              fontSize: 14,
            ),
            formatButtonDecoration: NeumorphicStyles.getNeumorphicElevated(
              // neumorphicBoxDecoration 대신 getNeumorphicElevated 사용
              color: NeumorphicStyles.backgroundColor.withOpacity(0.85),
              radius: 12,
              intensity: 0.05,
            ).copyWith(
              border: Border.all(
                color: NeumorphicStyles.textLight.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: NeumorphicStyles.textDark,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: NeumorphicStyles.textDark.withOpacity(0.8),
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: NeumorphicStyles.textDark.withOpacity(0.8),
            ),
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            // 캘린더 내부 스타일 변경
            markersAlignment: Alignment.bottomRight,
            weekendTextStyle: TextStyle(
              color: NeumorphicStyles.primaryButtonColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            holidayTextStyle: TextStyle(
              color: Colors.redAccent.withOpacity(0.9),
              fontWeight: FontWeight.bold,
            ),
            // todayDecoration, selectedDecoration 등은 builder에서 처리하므로 여기서는 기본값 사용 또는 제거
          ),
        ),
      ),
    );
  }

  Widget _buildEventList(TodoProvider provider) {
    final holidays = _getHolidaysForDay(
      _selectedDay ?? DateTime.now(),
    ); // _selectedDay가 null일 경우 대비
    final bool hasHoliday = holidays.isNotEmpty;
    const bottomNavHeight = 110.0; // 하단 네비게이션 바 높이 고려

    if (_selectedEvents.isEmpty && !hasHoliday) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: bottomNavHeight / 2,
          ), // 빈 상태일 때도 하단 여백 고려
          child: NeumorphicContainer(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 130,
            borderRadius: 16,
            color: NeumorphicStyles.backgroundColor.withOpacity(0.85),
            // intensity: 0.05, // NeumorphicContainer는 intensity를 받음
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note_outlined, // 아이콘 변경
                  size: 36, // 아이콘 크기 조정
                  color: NeumorphicStyles.textLight.withOpacity(0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedDay != null
                      ? '${_selectedDay!.month}월 ${_selectedDay!.day}일에 등록된 일정이 없습니다.' // 문구 수정
                      : '날짜를 선택해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: NeumorphicStyles.textLight.withOpacity(0.9),
                    fontSize: 15, // 폰트 크기 조정
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        bottomNavHeight + 16,
      ), // 하단 패딩 추가
      children: [
        if (hasHoliday)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: 12,
              color: NeumorphicStyles.backgroundColor.withOpacity(0.9),
              // intensity: 0.06, // NeumorphicContainer는 intensity를 받음
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.celebration_outlined,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "오늘의 공휴일 및 기념일",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicStyles.textDark.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...holidays.map(
                    (holiday) => Text(
                      "  • $holiday",
                      style: TextStyle(
                        fontSize: 14,
                        color: NeumorphicStyles.textLight.withOpacity(0.95),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_selectedEvents.isNotEmpty)
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
    const tagColors = AppConstants.tagColors; // 수정: const 제거

    return NeumorphicContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      // intensity: 0.08, // NeumorphicContainer는 intensity를 받음
      borderRadius: 16,
      color:
          todo.completed
              ? NeumorphicStyles.backgroundColor.withOpacity(
                0.75,
              ) // 완료 시 투명도 조정
              : NeumorphicStyles.backgroundColor.withOpacity(0.95), // 기본 투명도 조정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NeumorphicCheckbox(
                value: todo.completed,
                onChanged: (value) async {
                  await provider.toggleTodo(todo.id);
                  setState(() {
                    _selectedEvents = provider.getEventsForDay(_selectedDay!);
                  });
                },
                color: NeumorphicStyles.backgroundColor.withOpacity(
                  0.9,
                ), // 체크박스 배경색
                // intensity: 0.1, // NeumorphicCheckbox는 intensity를 직접 받지 않음
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600, // 굵기 조정
                    color:
                        todo.completed
                            ? NeumorphicStyles.textLight.withOpacity(
                              0.7,
                            ) // 완료 시 색상
                            : NeumorphicStyles.textDark.withOpacity(
                              0.9,
                            ), // 기본 색상
                    decoration:
                        todo.completed ? TextDecoration.lineThrough : null,
                    decorationColor: NeumorphicStyles.textLight.withOpacity(
                      0.7,
                    ), // 취소선 색상
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8), // 간격 추가
              NeumorphicButton(
                onPressed: () async {
                  await provider.deleteTodo(todo.id);
                  setState(() {
                    _selectedEvents = provider.getEventsForDay(_selectedDay!);
                  });
                },
                width: 36, // 버튼 크기 조정
                height: 36,
                padding: EdgeInsets.zero,
                borderRadius: 18, // 원형에 가깝게
                color: NeumorphicStyles.backgroundColor.withOpacity(0.9),
                // intensity: 0.1, // NeumorphicButton은 intensity를 직접 받지 않음
                child: Icon(
                  Icons.delete_outline_rounded, // 아이콘 변경
                  size: 20, // 아이콘 크기 조정
                  color: Colors.redAccent.withOpacity(0.8), // 색상 조정
                ),
              ),
            ],
          ),
          if (todo.memo != null && todo.memo!.isNotEmpty) ...[
            Padding(
              // 메모 패딩 추가
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 48,
                right: 8,
              ), // 체크박스 너비만큼 왼쪽 패딩
              child: Text(
                todo.memo!,
                style: TextStyle(
                  fontSize: 13, // 폰트 크기 조정
                  color: NeumorphicStyles.textLight.withOpacity(0.85), // 색상 조정
                  height: 1.4, // 줄 간격 조정
                ),
                maxLines: 3, // 최대 줄 수 증가
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (todo.tags.isNotEmpty) ...[
            Padding(
              // 태그 패딩 추가
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 48,
              ), // 체크박스 너비만큼 왼쪽 패딩
              child: Wrap(
                spacing: 6, // 태그 간 간격 조정
                runSpacing: 6,
                children:
                    todo.tags.map((tag) {
                      final index = todo.tags.indexOf(tag);
                      final color = tagColors[index % tagColors.length];
                      return NeumorphicContainer(
                        // 태그에 뉴모피즘 스타일 적용
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, // 내부 패딩 조정
                          vertical: 4,
                        ),
                        borderRadius: 10, // 테두리 반경 조정
                        color: color.withOpacity(0.12), // 배경 투명도 조정
                        intensity: 0.03, // 약한 뉴모피즘 효과
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 11, // 폰트 크기 조정
                            color: color.withOpacity(0.9), // 텍스트 투명도 조정
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
