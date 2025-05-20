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
    Key? key,
    required this.todos,
    required this.todoColors,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // 스크롤 물리 효과 제거로 중첩 스크롤 성능 개선
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final cardColor = todoColors[todo.id] ?? 
            (todo.hasDeadline 
                ? NeumorphicStyles.cardColors[1] 
                : NeumorphicStyles.cardColors[0]);
                
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 12,
            left: 20,
            right: 20,
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