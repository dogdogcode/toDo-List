import 'dart:ui'; // BackdropFilter 사용을 위해 추가
import 'package:flutter/material.dart';
import 'glassmorphism_container.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomDatePicker({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime selectedDate;
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    currentMonth = DateTime(selectedDate.year, selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              // 그라데이션 배경 적용
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDark
                      ? [
                        const Color(0xFF1A1A2E).withOpacity(0.9),
                        const Color(0xFF16213E).withOpacity(0.9),
                      ]
                      : [
                        const Color(0xFFF8FBFF).withOpacity(0.95),
                        const Color(0xFFE3F2FD).withOpacity(0.95),
                      ],
            ),
            boxShadow: [
              // 상단 그림자 추가
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ClipRRect(
            // 블러 효과를 위해 추가
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 핸들 바
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white54 : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // 헤더
                  GlassCard(
                    // GlassCard 사용
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    height: 48,
                    borderRadius: 16,
                    // backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: theme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '날짜 선택',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: isDark ? Colors.white : Colors.black87,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 월 네비게이션
                  GlassCard(
                    // GlassCard 사용
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    height: 48,
                    borderRadius: 16,
                    // backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
                          icon: const Icon(Icons.chevron_left),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        Text(
                          '${currentMonth.year}년 ${currentMonth.month}월',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(Icons.chevron_right),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 달력 그리드
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlassCard(
                        // GlassCard 사용
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        borderRadius: 16,
                        // backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                        child: Column(
                          children: [
                            // 요일 헤더
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children:
                                    ['일', '월', '화', '수', '목', '금', '토']
                                        .map(
                                          (day) => Expanded(
                                            child: Center(
                                              child: Text(
                                                day,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          isDark
                                                              ? Colors.white70
                                                              : Colors
                                                                  .grey
                                                                  .shade600,
                                                      fontSize: 12,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),

                            // 날짜 그리드
                            Expanded(child: _buildCalendarGrid()),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 확인 버튼
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onDateSelected(selectedDate);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '선택 완료',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday =
        firstDayOfMonth.weekday % 7; // 0: Sunday, 1: Monday ...
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 42, // 6주 * 7일
      itemBuilder: (context, index) {
        final day = index - startingWeekday + 1;

        if (day < 1 || day > daysInMonth) {
          return const SizedBox();
        }

        final date = DateTime(currentMonth.year, currentMonth.month, day);
        final isSelected =
            date.day == selectedDate.day &&
            date.month == selectedDate.month &&
            date.year == selectedDate.year;
        final isToday = _isToday(date);
        final isDisabled =
            date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

        return GestureDetector(
          onTap: isDisabled ? null : () => _selectDate(date),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color:
                  isSelected
                      ? theme.primaryColor
                      : isToday && !isDisabled
                      ? theme.primaryColor.withOpacity(0.25)
                      : Colors.transparent,
              border:
                  isToday && !isSelected && !isDisabled
                      ? Border.all(
                        color: theme.primaryColor.withOpacity(0.6),
                        width: 1.5,
                      )
                      : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color:
                      isDisabled
                          ? (isDark ? Colors.white24 : Colors.grey.shade400)
                          : isSelected
                          ? Colors.white
                          : isToday
                          ? theme.primaryColor
                          : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight:
                      isSelected || (isToday && !isDisabled)
                          ? FontWeight.bold
                          : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const CustomTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int selectedHour;
  late int selectedMinute;
  // ScrollController 초기화 시점 변경
  ScrollController? _hourController;
  ScrollController? _minuteController;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
    // WidgetsBinding.instance.addPostFrameCallback을 사용하여 레이아웃이 그려진 후 컨트롤러 초기화 및 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _hourController = ScrollController(
          initialScrollOffset: selectedHour * 30.0,
        ); // 아이템 높이에 따라 오프셋 조정 필요
        _minuteController = ScrollController(
          initialScrollOffset: (selectedMinute ~/ 5) * 30.0,
        ); // 아이템 높이에 따라 오프셋 조정 필요
        setState(() {}); // 컨트롤러가 설정되었음을 알리기 위해 setState 호출
      }
    });
  }

  @override
  void dispose() {
    _hourController?.dispose();
    _minuteController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 컨트롤러가 아직 초기화되지 않았으면 로딩 인디케이터 표시
    if (_hourController == null || _minuteController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              // 그라데이션 배경 적용
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDark
                      ? [
                        const Color(0xFF1A1A2E).withOpacity(0.9),
                        const Color(0xFF16213E).withOpacity(0.9),
                      ]
                      : [
                        const Color(0xFFF8FBFF).withOpacity(0.95),
                        const Color(0xFFE3F2FD).withOpacity(0.95),
                      ],
            ),
            boxShadow: [
              // 상단 그림자 추가
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ClipRRect(
            // 블러 효과를 위해 추가
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 핸들 바
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white54 : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // 헤더
                  GlassCard(
                    // GlassCard 사용
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    height: 48,
                    borderRadius: 16,
                    // backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: theme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '시간 선택',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: isDark ? Colors.white : Colors.black87,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 시간 표시
                  GlassCard(
                    // GlassCard 사용
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    height: 56,
                    borderRadius: 16,
                    // backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                    child: Center(
                      child: Text(
                        '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),

                  // 시간/분 선택기
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlassCard(
                        // GlassCard 사용
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        borderRadius: 16,
                        // backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                        child: Row(
                          children: [
                            // 시 선택
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '시',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDark
                                              ? Colors.white70
                                              : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            isDark
                                                ? Colors.white.withOpacity(0.08)
                                                : Colors.grey.withOpacity(
                                                  0.15,
                                                ), // 배경색 조정
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: GridView.builder(
                                        controller:
                                            _hourController!, // Null-aware operator 사용
                                        padding: const EdgeInsets.all(4),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              childAspectRatio: 1.3,
                                              crossAxisSpacing: 3,
                                              mainAxisSpacing: 3,
                                            ),
                                        itemCount: 24,
                                        itemBuilder: (context, index) {
                                          final isSelected =
                                              index == selectedHour;
                                          return GestureDetector(
                                            onTap:
                                                () => setState(
                                                  () => selectedHour = index,
                                                ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color:
                                                    isSelected
                                                        ? theme.primaryColor
                                                        : Colors.transparent,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  index.toString().padLeft(
                                                    2,
                                                    '0',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        isSelected
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                    color:
                                                        isSelected
                                                            ? Colors.white
                                                            : isDark
                                                            ? Colors.white70
                                                            : Colors
                                                                .grey
                                                                .shade700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 분 선택
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '분',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDark
                                              ? Colors.white70
                                              : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            isDark
                                                ? Colors.white.withOpacity(0.08)
                                                : Colors.grey.withOpacity(
                                                  0.15,
                                                ), // 배경색 조정
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: GridView.builder(
                                        controller:
                                            _minuteController!, // Null-aware operator 사용
                                        padding: const EdgeInsets.all(4),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              childAspectRatio: 1.3,
                                              crossAxisSpacing: 3,
                                              mainAxisSpacing: 3,
                                            ),
                                        itemCount: 12, // 5분 단위로 표시
                                        itemBuilder: (context, index) {
                                          final minute = index * 5;
                                          final isSelected =
                                              minute == selectedMinute;
                                          return GestureDetector(
                                            onTap:
                                                () => setState(
                                                  () => selectedMinute = minute,
                                                ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color:
                                                    isSelected
                                                        ? theme.primaryColor
                                                        : Colors.transparent,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  minute.toString().padLeft(
                                                    2,
                                                    '0',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        isSelected
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                    color:
                                                        isSelected
                                                            ? Colors.white
                                                            : isDark
                                                            ? Colors.white70
                                                            : Colors
                                                                .grey
                                                                .shade700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 확인 버튼
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onTimeSelected(
                            TimeOfDay(
                              hour: selectedHour,
                              minute: selectedMinute,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '선택 완료',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
