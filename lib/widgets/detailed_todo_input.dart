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
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: NeumorphicStyles.primaryButtonColor,
              onPrimary: Colors.white,
              surface: NeumorphicStyles.backgroundColor,
              onSurface: NeumorphicStyles.textDark,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: NeumorphicStyles.backgroundColor,
            ),
            // 뉴모피즘 스타일 추가
            datePickerTheme: DatePickerThemeData(
              dayStyle: TextStyle(color: NeumorphicStyles.textDark),
              weekdayStyle: TextStyle(color: NeumorphicStyles.textLight),
              // 오늘 날짜
              todayBackgroundColor: WidgetStatePropertyAll<Color>(
                NeumorphicStyles.backgroundColor,
              ),
              todayForegroundColor: WidgetStatePropertyAll<Color>(
                NeumorphicStyles.secondaryButtonColor,
              ),
              // 선택된 날짜
              dayBackgroundColor: WidgetStateProperty.resolveWith<Color>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return NeumorphicStyles.backgroundColor; // 배경색 변경
                }
                return NeumorphicStyles.backgroundColor;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith<Color>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return NeumorphicStyles.primaryButtonColor; // 글자 색상 변경
                }
                return NeumorphicStyles.textDark;
              }),
              rangePickerBackgroundColor: NeumorphicStyles.backgroundColor,
              backgroundColor: NeumorphicStyles.backgroundColor,
              headerBackgroundColor: NeumorphicStyles.backgroundColor,
            ),
          ),
          child: NeumorphicContainer(
            // 뉴모피즘 스타일 적용: 여백과 elevation 효과 부여
            padding: const EdgeInsets.all(8),
            // NeumorphicStyles.getNeumorphicElevated 사용 가능
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
    if (_titleController.text.isEmpty || _selectedDate == null) {
      // 입력 오류 메시지를 뉴모피즘 스타일 팝업으로 표시
      await showDialog(
        context: context,
        builder:
            (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '입력 오류',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('제목과 날짜를 입력해주세요'),
                    const SizedBox(height: 20),
                    NeumorphicButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              ),
            ),
      );
      return;
    }
    // 현재 선택된 날짜의 시간을 정확하게 설정 (시간대 문제 해결)
    final deadline = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      23,
      59,
      59,
    );

    final todo = Todo.detailed(
      title: _titleController.text,
      deadline: deadline,
      memo: _memoController.text.isEmpty ? null : _memoController.text,
      tags: _tags.isEmpty ? null : _tags,
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
        color: NeumorphicStyles.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: NeumorphicStyles.darkShadow.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이모티콘과 타이틀
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: NeumorphicStyles.primaryButtonColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '기간이 있는 할 일 추가',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NeumorphicStyles.textDark,
                      ),
                    ),
                  ],
                ),
                // 닫기 버튼
                NeumorphicButton(
                  onPressed: () => Navigator.pop(context),
                  width: 40,
                  height: 40,
                  borderRadius: 12,
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    Icons.close,
                    color: NeumorphicStyles.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 제목 입력
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: NeumorphicStyles.getNeumorphicElevated(
                radius: 12,
                intensity: 0.05,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.title,
                    color: NeumorphicStyles.primaryButtonColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '제목',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: NeumorphicStyles.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            NeumorphicTextField(
              controller: _titleController,
              hintText: '할 일 제목을 입력하세요',
              borderRadius: 16,
              textStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black38,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),

            // 날짜 선택
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: NeumorphicStyles.getNeumorphicElevated(
                radius: 12,
                intensity: 0.05,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: NeumorphicStyles.primaryButtonColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '날짜',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: NeumorphicStyles.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            NeumorphicButton(
              onPressed: () => _selectDate(context),
              color: NeumorphicStyles.backgroundColor,
              height: 55,
              borderRadius: 16,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: NeumorphicStyles.textDark,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate == null
                        ? '날짜 선택'
                        : '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일',
                    style: TextStyle(
                      color:
                          _selectedDate == null
                              ? NeumorphicStyles.textLight
                              : NeumorphicStyles.textDark,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 메모 입력
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: NeumorphicStyles.getNeumorphicElevated(
                radius: 12,
                intensity: 0.05,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note,
                    color: NeumorphicStyles.primaryButtonColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '메모',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: NeumorphicStyles.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: NeumorphicStyles.getNeumorphicPressed(
                radius: 16,
                intensity: 0.08,
              ),
              child: TextField(
                controller: _memoController,
                decoration: const InputDecoration(
                  hintText: '메모를 입력하세요 (선택사항)',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.black38,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 20),

            // 태그 입력
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: NeumorphicStyles.getNeumorphicElevated(
                radius: 12,
                intensity: 0.05,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.label,
                    color: NeumorphicStyles.primaryButtonColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '태그',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: NeumorphicStyles.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NeumorphicTextField(
                    controller: _tagController,
                    hintText: '태그 입력 (선택사항)',
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black38,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                NeumorphicButton(
                  onPressed: _addTag,
                  width: 80,
                  height: 50,
                  color: NeumorphicStyles.primaryButtonColor,
                  child: const Center(
                    child: Text(
                      '추가',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 태그 목록 표시
            if (_tags.isNotEmpty) ...[
              const Text(
                '추가된 태그:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: NeumorphicStyles.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _tags
                        .map(
                          (tag) => NeumorphicContainer(
                            height: 32,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            borderRadius: 16,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tag,
                                  size: 14,
                                  color: NeumorphicStyles.primaryButtonColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tag,
                                  style: const TextStyle(
                                    color: NeumorphicStyles.textDark,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _removeTag(tag),
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 26),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // 저장 버튼
            NeumorphicButton(
              onPressed: _saveTodo,
              color: NeumorphicStyles.primaryButtonColor,
              height: 55,
              child: const Center(
                child: Text(
                  '저장하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
