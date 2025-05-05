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
          ),
          child: child!,
        );
      },
    );
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
      // 제목이나 날짜가 없으면 경고 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('제목과 날짜를 입력해주세요'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final todo = Todo.detailed(
      title: _titleController.text,
      deadline: _selectedDate!,
      memo: _memoController.text.isEmpty ? null : _memoController.text,
      tags: _tags.isEmpty ? null : _tags,
    );

    try {
      // 저장 작업 실행 (비동기로 처리)
      await widget.onSave(todo);
      
      // context가 여전히 유효한지 확인 후 화면 닫기
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // 에러 발생 시 처리
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
                  Icon(Icons.title, color: NeumorphicStyles.primaryButtonColor, size: 20),
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
                  Icon(Icons.event, color: NeumorphicStyles.primaryButtonColor, size: 20),
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
                  Icon(Icons.note, color: NeumorphicStyles.primaryButtonColor, size: 20),
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
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(color: NeumorphicStyles.textDark),
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
                  Icon(Icons.label, color: NeumorphicStyles.primaryButtonColor, size: 20),
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
                            color: Colors.red.withValues(alpha: 0.1),
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
