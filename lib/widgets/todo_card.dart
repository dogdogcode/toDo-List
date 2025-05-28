import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';
import 'glassmorphism_container.dart';

class TodoCard extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const TodoCard({
    Key? key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Slidable(
      key: ValueKey(todo.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: Colors.blue.withOpacity(0.8),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: '편집',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red.withOpacity(0.8),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '삭제',
            borderRadius: BorderRadius.only(
              topRight: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
              topLeft: onEdit == null ? const Radius.circular(16) : Radius.zero,
              bottomLeft: onEdit == null ? const Radius.circular(16) : Radius.zero,
            ),
          ),
        ],
      ),
      child: GlassCard(
        backgroundColor: _getCardColor(),
        onTap: onToggle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 완료 체크박스
                Container(
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  child: InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: todo.isCompleted
                              ? Colors.green
                              : (isDark ? Colors.white54 : Colors.grey),
                          width: 2,
                        ),
                        color: todo.isCompleted
                            ? Colors.green
                            : Colors.transparent,
                      ),
                      child: todo.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                // 할일 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        todo.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted
                              ? (isDark ? Colors.white54 : Colors.grey)
                              : (isDark ? Colors.white : Colors.black87),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // 설명
                      if (todo.description != null && todo.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            todo.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.isCompleted
                                  ? (isDark ? Colors.white38 : Colors.grey.shade600)
                                  : (isDark ? Colors.white70 : Colors.grey.shade700),
                            ),
                          ),
                        ),
                      // 마감일
                      if (todo.hasDeadline)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: todo.isOverdue
                                    ? Colors.red
                                    : (isDark ? Colors.white70 : Colors.grey.shade600),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDueDate(todo.dueDate!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: todo.isOverdue
                                      ? Colors.red
                                      : (isDark ? Colors.white70 : Colors.grey.shade600),
                                  fontWeight: todo.isOverdue
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              if (todo.isOverdue)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '기한 초과',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // 생성일
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 36),
              child: Text(
                '생성일: ${DateFormat('MM/dd HH:mm').format(todo.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _getCardColor() {
    if (todo.isCompleted) {
      return Colors.green.withOpacity(0.1);
    } else if (todo.isOverdue) {
      return Colors.red.withOpacity(0.1);
    } else if (todo.hasDeadline) {
      return Colors.blue.withOpacity(0.1);
    }
    return null;
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay == today) {
      return '오늘 ${DateFormat('HH:mm').format(dueDate)}';
    } else if (dueDay == tomorrow) {
      return '내일 ${DateFormat('HH:mm').format(dueDate)}';
    } else if (dueDate.year == now.year) {
      return DateFormat('MM/dd HH:mm').format(dueDate);
    } else {
      return DateFormat('yyyy/MM/dd HH:mm').format(dueDate);
    }
  }
}

// 할일 섹션 헤더
class TodoSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color? color;

  const TodoSectionHeader({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? theme.primaryColor).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color ?? theme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (color ?? theme.primaryColor).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: color ?? theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
