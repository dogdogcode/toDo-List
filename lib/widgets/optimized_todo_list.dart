import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../utils/neumorphic_styles.dart';
import '../widgets/todo_list_item.dart';

class OptimizedTodoList extends StatelessWidget {
  final List<Todo> todos;
  final Map<String, Color> todoColors;
  final void Function(String) onToggle; // 명시적 타입 선언
  final void Function(String) onDelete; // 명시적 타입 선언

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
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final cardColor =
            todoColors[todo.id] ??
            (todo.hasDeadline
                ? NeumorphicStyles.cardColors[1]
                : NeumorphicStyles.cardColors[0]);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
