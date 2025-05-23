import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../widgets/todo_list_item.dart';
import '../widgets/detailed_todo_input.dart';
import '../utils/neumorphic_styles.dart';

class OptimizedTodoList extends StatelessWidget {
  final List<Todo> todos;
  final Map<String, Color> todoColors;
  final Function(String) onToggle;
  final Function(String) onDelete;

  const OptimizedTodoList({
    super.key,
    required this.todos,
    required this.todoColors,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // 스크롤 물리 효과를 플랫폼 기본값으로 변경하여 자연스러운 스크롤 제공
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final cardColor =
            todoColors[todo.id] ??
            (todo.hasDeadline
                ? NeumorphicStyles.cardColors[1]
                : NeumorphicStyles.cardColors[0]);

        return Padding(
          // 좌우 패딩을 줄여서 카드 너비를 확보하고, 상하 패딩을 조정하여 아이템 간 간격 개선
          padding: const EdgeInsets.only(
            bottom: 8, // 아이템 간 하단 간격 조정
            left: 16, // 좌측 패딩 조정
            right: 16, // 우측 패딩 조정
          ),
          child: TodoListItem(
            todo: todo,
            onToggle: () => onToggle(todo.id),
            onDelete: () => onDelete(todo.id),
            cardColor: cardColor,
          ),
        );
      },
    );
  }
}
