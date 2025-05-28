import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_item.dart';
import '../providers/todo_provider.dart';
import '../utils/date_helper.dart';
import '../widgets/glassmorphism_container.dart';

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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

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
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
        child: SlideTransition(
          position: _slideAnimation,
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isDark
                            ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                            : [
                              const Color(0xFFF8FBFF),
                              const Color(0xFFE3F2FD),
                            ],
                  ),
                ),
                child: Column(
                  children: [
                    // 핸들 바
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white54 : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // 헤더
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text(
                            '새로운 할일',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _closeScreen,
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 폼 내용
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 제목 입력
                              _buildTitleField(),
                              const SizedBox(height: 20),

                              // 설명 입력
                              _buildDescriptionField(),
                              const SizedBox(height: 20),

                              // 마감일 설정
                              _buildDeadlineSection(),

                              if (_hasDeadline) ...[
                                const SizedBox(height: 20),
                                _buildDateTimeSelectors(),
                              ],

                              const SizedBox(height: 40),

                              // 저장 버튼
                              _buildSaveButton(),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: '할일 제목',
          hintText: '무엇을 해야 하나요?',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.title),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '제목을 입력해주세요';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _buildDescriptionField() {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: TextFormField(
        controller: _descriptionController,
        decoration: const InputDecoration(
          labelText: '설명 (선택사항)',
          hintText: '추가 설명을 입력하세요',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.description),
        ),
        maxLines: 3,
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget _buildDeadlineSection() {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
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
        title: const Text('마감일 설정'),
        subtitle: Text(_hasDeadline ? '마감일이 있는 할일' : '기간 없는 할일'),
        secondary: Icon(
          _hasDeadline ? Icons.schedule : Icons.task_alt,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildDateTimeSelectors() {
    return Column(
      children: [
        // 날짜 선택
        GlassCard(
          margin: EdgeInsets.zero,
          onTap: _selectDate,
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('날짜'),
            subtitle: Text(
              _selectedDate != null
                  ? DateHelper.formatDate(_selectedDate!)
                  : '날짜를 선택하세요',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
        const SizedBox(height: 12),

        // 시간 선택
        GlassCard(
          margin: EdgeInsets.zero,
          onTap: _selectTime,
          child: ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('시간'),
            subtitle: Text(
              _selectedTime != null
                  ? _selectedTime!.format(context)
                  : '시간을 선택하세요',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTodo,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  '할일 추가',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
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
