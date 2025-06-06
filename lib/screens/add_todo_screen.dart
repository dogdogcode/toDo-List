import 'dart:ui'; // BackdropFilter 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_item.dart';
import '../providers/todo_provider.dart';
import '../utils/date_helper.dart';
import '../widgets/custom_date_time_picker.dart';
import '../widgets/glassmorphism_container.dart'; // GlassCard 사용

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({Key? key}) : super(key: key);

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _hasDeadline = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // 애니메이션 시작
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        // 전체 화면을 약간 어둡게 하여 모달 강조
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)), // 배경 투명도 감소
        child: SlideTransition(
          position: _slideAnimation,
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                // DraggableScrollableSheet의 배경
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    // 그라데이션 배경 적용 (투명도 증가)
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isDark
                            ? [
                              const Color(
                                0xFF1A1A2E,
                              ).withOpacity(0.6), // 더욱 투명하게
                              const Color(0xFF16213E).withOpacity(0.5),
                            ]
                            : [
                              const Color(
                                0xFFF8FBFF,
                              ).withOpacity(0.65), // 더욱 투명하게
                              const Color(0xFFE3F2FD).withOpacity(0.6),
                            ],
                    stops: const [0.0, 1.0],
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                    child: Column(
                      children: [
                        // 핸들 바
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                isDark ? Colors.white54 : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // 헤더
                        GlassCard(
                          // GlassCard 사용
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          borderRadius: 20,
                          // backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.add_task,
                                  color: theme.primaryColor,
                                  size: 24, // 아이콘 크기 증가
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '새로운 할일',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22, // 글자 크기 증가
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _closeScreen,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (isDark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color:
                                          isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 폼 내용
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // 다른 부분 터치시 키보드 숨기기
                              FocusScope.of(context).unfocus();
                            },
                            behavior: HitTestBehavior.translucent,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 제목 입력
                                    _buildTitleField(),
                                    const SizedBox(height: 12),

                                    // 설명 입력
                                    _buildDescriptionField(),
                                    const SizedBox(height: 16),

                                    // 마감일 설정
                                    _buildDeadlineSection(),

                                    if (_hasDeadline) ...[
                                      const SizedBox(height: 16),
                                      _buildDateTimeSelectors(), // 이 내부도 GlassCard 스타일 적용 고려
                                    ],

                                    const SizedBox(height: 24),

                                    // 저장 버튼
                                    _buildSaveButton(), // 이 버튼도 GlassCard 스타일 적용 고려

                                    const SizedBox(height: 16),
                                  ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {}, // 빈 함수로 터치 효과만
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.title, color: theme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '할일 제목',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: '무엇을 해야 하나요?',
                          border: InputBorder.none,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white54 : Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {}, // 빈 함수로 터치 효과만
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.description, color: theme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '설명 (선택사항)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: '추가 설명을 입력하세요',
                          border: InputBorder.none,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white54 : Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlineSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      // GlassCard 사용 (height 제거하여 내용에 맞게 자동 조정)
      borderRadius: 20,
      padding: const EdgeInsets.all(0), // 내부 패딩 제거
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              _hasDeadline = !_hasDeadline;
              if (!_hasDeadline) {
                _selectedDate = null;
                _selectedTime = null;
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // 패딩 증가
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12), // 패딩 통일
                  decoration: BoxDecoration(
                    color:
                        _hasDeadline
                            ? theme.primaryColor.withOpacity(0.2)
                            : (isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(14), // 보더 랄디어스 통일
                  ),
                  child: Icon(
                    _hasDeadline ? Icons.schedule : Icons.task_alt,
                    color:
                        _hasDeadline
                            ? theme.primaryColor
                            : (isDark ? Colors.white54 : Colors.grey.shade600),
                    size: 24, // 아이콘 크기 통일
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start, // center에서 start로 변경
                    mainAxisSize: MainAxisSize.min, // 크기를 최소로 제한
                    children: [
                      Text(
                        '마감일 설정',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16, // 글자 크기 통일
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4), // 간격 증가
                      Text(
                        _hasDeadline ? '마감일이 있는 할일' : '기간 없는 할일',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 14, // 글자 크기 증가
                          fontWeight: FontWeight.w500, // 글자 두께 증가
                          color:
                              _hasDeadline
                                  ? theme.primaryColor
                                  : (isDark
                                      ? Colors.white54
                                      : Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: _hasDeadline,
                    onChanged: (value) {
                      setState(() {
                        _hasDeadline = value;
                        if (!value) {
                          _selectedDate = null;
                          _selectedTime = null;
                        }
                      });
                    },
                    activeColor: theme.primaryColor,
                    activeTrackColor: theme.primaryColor.withOpacity(0.3),
                    inactiveThumbColor:
                        isDark ? Colors.white54 : Colors.grey.shade400,
                    inactiveTrackColor:
                        isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelectors() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // 날짜 선택
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: GlassCard(
              // GlassCard 사용
              height: 120,
              borderRadius: 20,
              padding: EdgeInsets.zero, // GlassCard 내부 패딩 제거 후 직접 관리
              // backgroundColor: theme.primaryColor.withOpacity(0.03),
              child: Stack(
                children: [
                  // 배경 장식
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // 콘텐츠
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '날짜',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color:
                                    isDark
                                        ? Colors.white70
                                        : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 14, // 글자 크기 통일
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedDate != null) ...[
                              Text(
                                DateHelper.formatDate(
                                  _selectedDate!,
                                ).split(' ')[0],
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20, // 글자 크기 증가
                                  color: theme.primaryColor,
                                ),
                              ),
                              if (DateHelper.formatDate(
                                _selectedDate!,
                              ).contains(' '))
                                Text(
                                  DateHelper.formatDate(
                                    _selectedDate!,
                                  ).split(' ').skip(1).join(' '),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 15, // 글자 크기 증가
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.grey.shade600,
                                  ),
                                ),
                            ] else ...[
                              Text(
                                '선택하세요',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 17, // 글자 크기 증가
                                  color:
                                      isDark
                                          ? Colors.white38
                                          : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 시간 선택
        Expanded(
          child: GestureDetector(
            onTap: _selectTime,
            child: GlassCard(
              // GlassCard 사용
              height: 120,
              borderRadius: 20,
              padding: EdgeInsets.zero, // GlassCard 내부 패딩 제거 후 직접 관리
              // backgroundColor: theme.primaryColor.withOpacity(0.03),
              child: Stack(
                children: [
                  // 배경 장식
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // 콘텐츠
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '시간',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color:
                                    isDark
                                        ? Colors.white70
                                        : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 14, // 글자 크기 통일
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : '선택하세요',
                          style:
                              _selectedTime != null
                                  ? theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20, // 글자 크기 증가
                                    color: theme.primaryColor,
                                  )
                                  : theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 17, // 글자 크기 증가
                                    color:
                                        isDark
                                            ? Colors.white38
                                            : Colors.grey.shade400,
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
      ],
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);

    return Container(
      // GlassCard 스타일 직접 적용 (그라데이션 버튼)
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.4), // 그림자 강화
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _isLoading ? null : _saveTodo,
          child: Center(
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '할일 추가',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CustomDatePicker(
            initialDate: _selectedDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
    );
  }

  Future<void> _selectTime() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CustomTimePicker(
            initialTime: _selectedTime ?? TimeOfDay.now(),
            onTimeSelected: (time) {
              setState(() {
                _selectedTime = time;
              });
            },
          ),
    );
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hasDeadline && (_selectedDate == null || _selectedTime == null)) {
      _showErrorSnackBar('마감일을 완전히 설정해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DateTime? dueDate;
      if (_hasDeadline && _selectedDate != null && _selectedTime != null) {
        dueDate = DateHelper.combineDateAndTime(_selectedDate!, _selectedTime!);
      }

      final todo = TodoItem(
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await context.read<TodoProvider>().addTodo(todo);

      if (success) {
        _showSuccessSnackBar('할일이 추가되었습니다');
        _closeScreen();
      } else {
        _showErrorSnackBar('할일 추가에 실패했습니다');
      }
    } catch (e) {
      _showErrorSnackBar('오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _closeScreen() async {
    await _slideController.reverse();
    await _fadeController.reverse();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
