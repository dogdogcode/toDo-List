import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/neumorphic_styles.dart';
import '../services/todo_service.dart';
import '../models/todo.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Todo>> _eventsByDate = {};
  List<Todo> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTodos();
  }

  // SharedPreferences에서 할 일 목록 불러오기
  Future<void> _loadTodos() async {
    final todos = await TodoService.getTodos();
    final eventsByDate = <DateTime, List<Todo>>{};
    
    for (var todo in todos) {
      if (todo.hasDeadline && todo.deadline != null) {
        final date = DateTime(
          todo.deadline!.year,
          todo.deadline!.month,
          todo.deadline!.day,
        );
        if (eventsByDate[date] == null) {
          eventsByDate[date] = [];
        }
        eventsByDate[date]!.add(todo);
      }
    }
    
    setState(() {
      _eventsByDate = eventsByDate;
      _selectedEvents = _getEventsForDay(_selectedDay!);
    });
  }

  List<Todo> _getEventsForDay(DateTime day) {
    return _eventsByDate[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicStyles.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),
            
            // 캘린더
            _buildCalendar(),
            
            // 선택한 날짜의 할 일 목록
            Expanded(
              child: _buildEventList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: NeumorphicStyles.secondaryButtonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '일정 관리',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: NeumorphicStyles.textDark,
                ),
              ),
            ],
          ),
          // 오늘 날짜로 이동 버튼
          NeumorphicButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
                _selectedEvents = _getEventsForDay(_selectedDay!);
              });
            },
            width: 40,
            height: 40,
            borderRadius: 20,
            padding: EdgeInsets.zero,
            child: const Icon(
              Icons.today,
              color: NeumorphicStyles.textDark,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: NeumorphicContainer(
        width: double.infinity,
        height: 380, // 고정된 높이 추가
        intensity: 0.05,
        child: TableCalendar(
          firstDay: DateTime.utc(2021, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay,
          calendarStyle: CalendarStyle(
            // 이벤트 표시기 (점)
            markerDecoration: BoxDecoration(
              color: NeumorphicStyles.primaryButtonColor,
              shape: BoxShape.circle,
            ),
            markerSize: 6.0,
            markersMaxCount: 3,
            markersAnchor: 0.7,
            // 오늘 날짜 스타일
            todayDecoration: BoxDecoration(
              color: NeumorphicStyles.secondaryButtonColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: NeumorphicStyles.secondaryButtonColor,
                width: 1.5,
              ),
            ),
            // 선택된 날짜 스타일
            selectedDecoration: BoxDecoration(
              color: NeumorphicStyles.primaryButtonColor,
              shape: BoxShape.circle,
            ),
            // 주말 스타일
            weekendTextStyle: TextStyle(
              color: NeumorphicStyles.secondaryButtonColor,
            ),
            // 외부 날짜 스타일
            outsideDaysVisible: false,
            // 오늘 텍스트 스타일
            todayTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: NeumorphicStyles.secondaryButtonColor,
            ),
            // 선택된 날짜 텍스트 스타일
            selectedTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            // 기본 텍스트 스타일
            defaultTextStyle: TextStyle(
              color: NeumorphicStyles.textDark,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: NeumorphicStyles.textDark,
            ),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: NeumorphicStyles.textDark,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: NeumorphicStyles.textDark,
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedEvents = _getEventsForDay(selectedDay);
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          calendarBuilders: CalendarBuilders(
            // 선택된 날짜 커스텀 빌더
            selectedBuilder: (context, date, _) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: NeumorphicStyles.primaryButtonColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${date.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (_selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: NeumorphicStyles.textLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '${_selectedDay?.month}월 ${_selectedDay?.day}일에 할 일이 없습니다',
              style: TextStyle(
                color: NeumorphicStyles.textLight,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final todo = _selectedEvents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEventCard(todo),
        );
      },
    );
  }

  Widget _buildEventCard(Todo todo) {
    // 태그별 색상 배열
    final tagColors = [
      NeumorphicStyles.primaryButtonColor,
      NeumorphicStyles.secondaryButtonColor,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];

    return NeumorphicContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      intensity: 0.08,
      child: Row(
        children: [
          // 체크박스
          NeumorphicCheckbox(
            value: todo.completed,
            onChanged: (value) async {
              await TodoService.toggleTodoCompleted(todo.id);
              _loadTodos();
            },
          ),
          const SizedBox(width: 16),
          // 할 일 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NeumorphicStyles.textDark,
                    decoration: todo.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (todo.memo != null && todo.memo!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    todo.memo!,
                    style: TextStyle(
                      fontSize: 14,
                      color: NeumorphicStyles.textLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (todo.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: todo.tags.map((tag) {
                      final index = todo.tags.indexOf(tag);
                      final color = tagColors[index % tagColors.length];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
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
          // 삭제 버튼
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            onPressed: () async {
              await TodoService.deleteTodo(todo.id);
              _loadTodos();
            },
          ),
        ],
      ),
    );
  }
}
