import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/neumorphic_styles.dart';

class DetailedTodoInput extends StatefulWidget {
  final Function(Todo) onSave;

  const DetailedTodoInput({super.key, required this.onSave});

  @override
  DetailedTodoInputState createState() => DetailedTodoInputState();
}

class DetailedTodoInputState extends State<DetailedTodoInput> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  DateTime? _selectedDate;
  final List<String> _tags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // 날짜 선택 대화상자 표시
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // 오늘부터 선택 가능
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: NeumorphicStyles.primaryButtonColor,
              onPrimary: Colors.white,
              surface: NeumorphicStyles.backgroundColor.withOpacity(
                0.9,
              ), // 반투명 효과
              onSurface: NeumorphicStyles.textDark,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: NeumorphicStyles.backgroundColor.withOpacity(
                0.9,
              ), // 반투명 효과
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ), // 모서리 둥글게
            ),
            datePickerTheme: DatePickerThemeData(
              dayStyle: TextStyle(
                color: NeumorphicStyles.textDark,
                fontSize: 14,
              ),
              weekdayStyle: TextStyle(
                color: NeumorphicStyles.textLight.withOpacity(0.8),
                fontSize: 12,
              ),
              todayBackgroundColor: WidgetStatePropertyAll<Color>(
                NeumorphicStyles.secondaryButtonColor.withOpacity(
                  0.2,
                ), // 오늘 날짜 배경 강조
              ),
              todayForegroundColor: WidgetStatePropertyAll<Color>(
                NeumorphicStyles.secondaryButtonColor, // 오늘 날짜 텍스트 강조
              ),
              dayBackgroundColor: WidgetStateProperty.resolveWith<Color>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return NeumorphicStyles.primaryButtonColor.withOpacity(
                    0.8,
                  ); // 선택된 날짜 배경색 변경 및 반투명
                }
                return Colors.transparent; // 기본 배경 투명
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith<Color>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white; // 선택된 날짜 글자 색상 흰색으로 변경
                }
                return NeumorphicStyles.textDark;
              }),
              headerBackgroundColor: NeumorphicStyles.backgroundColor
                  .withOpacity(0.9), // 반투명 효과
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ), // 모서리 둥글게
              yearOverlayColor: WidgetStatePropertyAll<Color>(
                NeumorphicStyles.primaryButtonColor.withOpacity(0.1),
              ),
              rangePickerHeaderBackgroundColor: NeumorphicStyles.backgroundColor
                  .withOpacity(0.9),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: NeumorphicStyles.backgroundColor.withOpacity(
                0.95,
              ), // 반투명 배경
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // 그림자 연하게
                  offset: const Offset(5, 5),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.7), // 밝은 그림자 연하게
                  offset: const Offset(-5, -5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: child!,
          ),
        );
      },
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 태그 추가
  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  // 태그 삭제
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  // 할 일 저장
  Future<void> _saveTodo() async {
    if (_titleController.text.isEmpty) {
      await showDialog(
        context: context,
        builder:
            (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: NeumorphicContainer(
                color: NeumorphicStyles.backgroundColor.withOpacity(0.95),
                borderRadius: 16,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '입력 오류',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NeumorphicStyles.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '제목을 입력해주세요.',
                      style: TextStyle(
                        color: NeumorphicStyles.textDark,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    NeumorphicButton(
                      onPressed: () => Navigator.of(context).pop(),
                      width: double.infinity,
                      height: 48,
                      borderRadius: 12,
                      color: NeumorphicStyles.primaryButtonColor.withOpacity(
                        0.85,
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
      return;
    }

    DateTime? deadline;
    if (_selectedDate != null) {
      deadline = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        23, // 마감일의 가장 마지막 시간으로 설정
        59,
        59,
      );
    }

    final todo = Todo.detailed(
      title: _titleController.text,
      deadline: deadline, // nullable로 변경된 deadline 사용
      memo: _memoController.text.isEmpty ? null : _memoController.text,
      tags: _tags.isEmpty ? [] : _tags, // 빈 리스트로 초기화
    );

    try {
      await widget.onSave(todo);
      if (!mounted) return;
      Navigator.pop(context); // 저장 성공 시 모달 닫기
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: NeumorphicStyles.backgroundColor.withOpacity(0.97), // 반투명도 미세 조정
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28), // 모서리 반지름 조정
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: NeumorphicStyles.darkShadow.withValues(
              alpha: 0.12,
            ), // 그림자 연하게
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20), // 상하 패딩 조정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0), // 헤더 하단 여백 추가
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: NeumorphicStyles.primaryButtonColor
                              .withOpacity(0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_calendar_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '새로운 할 일', // 타이틀 변경
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicStyles.textDark,
                        ),
                      ),
                    ],
                  ),
                  NeumorphicButton(
                    onPressed: () => Navigator.pop(context),
                    width: 38,
                    height: 38,
                    borderRadius: 10,
                    color: NeumorphicStyles.backgroundColor.withOpacity(0.95),
                    padding: EdgeInsets.zero,
                    child: Icon(
                      Icons.close_rounded, // 아이콘 변경
                      color: NeumorphicStyles.textLight.withOpacity(0.9),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // 제목 입력
            _buildSectionTitle(icon: Icons.title_rounded, title: '제목'),
            const SizedBox(height: 10),
            NeumorphicTextField(
              controller: _titleController,
              hintText: '무엇을 해야 하나요?',
              borderRadius: 14,
              textStyle: const TextStyle(
                fontSize: 16,
                color: NeumorphicStyles.textDark,
                fontWeight: FontWeight.w500,
              ),
              // NeumorphicTextField는 contentPadding을 직접 지원합니다.
              // hintStyle도 NeumorphicTextField 내부에서 처리됩니다.
            ),
            const SizedBox(height: 20),

            // 날짜 선택
            _buildSectionTitle(
              icon: Icons.calendar_today_rounded,
              title: '마감일 (선택)',
            ),
            const SizedBox(height: 10),
            NeumorphicButton(
              onPressed: () => _selectDate(context),
              color: NeumorphicStyles.backgroundColor.withOpacity(0.95),
              borderRadius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_available_rounded,
                        color:
                            _selectedDate != null
                                ? NeumorphicStyles.primaryButtonColor
                                : NeumorphicStyles.textLight.withOpacity(0.8),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? '날짜를 선택해주세요'
                            : '${_selectedDate!.year}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.day.toString().padLeft(2, '0')}', // 날짜 형식 변경
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              _selectedDate != null
                                  ? NeumorphicStyles.textDark
                                  : NeumorphicStyles.textLight.withOpacity(0.8),
                          fontWeight:
                              _selectedDate != null
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedDate != null)
                    NeumorphicButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = null;
                        });
                      },
                      width: 30,
                      height: 30,
                      borderRadius: 8,
                      padding: EdgeInsets.zero,
                      color: NeumorphicStyles.backgroundColor.withOpacity(0.9),
                      child: Icon(
                        Icons.clear_rounded,
                        size: 18,
                        color: NeumorphicStyles.textLight.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 메모 입력
            _buildSectionTitle(icon: Icons.notes_rounded, title: '메모 (선택)'),
            const SizedBox(height: 10),
            // NeumorphicTextField가 minLines/maxLines를 지원하지 않으므로, 일반 TextField에 뉴모피즘 스타일 적용
            Container(
              decoration: NeumorphicStyles.getNeumorphicPressed(
                radius: 14,
                intensity: 0.08,
              ),
              child: TextField(
                controller: _memoController,
                decoration: InputDecoration(
                  hintText: '자세한 내용을 기록해보세요',
                  hintStyle: TextStyle(
                    color: NeumorphicStyles.textLight.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: NeumorphicStyles.textDark,
                ),
                minLines: 2,
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 20),

            // 태그 입력
            _buildSectionTitle(icon: Icons.tag_rounded, title: '태그 (선택)'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: NeumorphicTextField(
                    controller: _tagController,
                    hintText: '쉼표(,)로 태그를 구분해주세요',
                    borderRadius: 14,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      color: NeumorphicStyles.textDark,
                    ),
                    // NeumorphicTextField는 contentPadding을 직접 지원합니다.
                    // hintStyle도 NeumorphicTextField 내부에서 처리됩니다.
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 10),
                NeumorphicButton(
                  onPressed: _addTag,
                  width: 50,
                  height: 50,
                  borderRadius: 14,
                  color: NeumorphicStyles.secondaryButtonColor.withOpacity(
                    0.85,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0), // 태그 목록 상단 여백 추가
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children:
                      _tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 13,
                              color: NeumorphicStyles.primaryButtonColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onDeleted: () => _removeTag(tag),
                          backgroundColor: NeumorphicStyles.primaryButtonColor
                              .withOpacity(0.12),
                          deleteIconColor: NeumorphicStyles.primaryButtonColor
                              .withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: NeumorphicStyles.primaryButtonColor
                                  .withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 1,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          deleteIcon: const Icon(
                            Icons.cancel_rounded,
                            size: 18,
                          ), // 삭제 아이콘 변경
                        );
                      }).toList(),
                ),
              ),
            const SizedBox(height: 28),

            // 저장 버튼
            NeumorphicButton(
              onPressed: _saveTodo,
              width: double.infinity,
              height: 56,
              borderRadius: 16,
              color: NeumorphicStyles.primaryButtonColor.withOpacity(0.9),
              child: const Text(
                '저장하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 타이틀 위젯
  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(
          icon,
          color: NeumorphicStyles.textLight.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: NeumorphicStyles.textLight.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
