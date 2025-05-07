import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../utils/neumorphic_styles.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Color cardColor;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final lightColor = Color.lerp(cardColor, Colors.white, 0.5)!;

    return NeumorphicContainer(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: cardColor.withValues(alpha: 240),
      borderRadius: 16,
      intensity: 0.15,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onToggle,
          splashColor: lightColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 개선된 체크박스
                NeumorphicCheckbox(
                  value: todo.completed,
                  onChanged: (_) => onToggle(),
                  color: NeumorphicStyles.backgroundColor,
                  size: 24,
                ),

                const SizedBox(width: 16),

                // 제목, 메모, 태그 등 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 제목
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration:
                              todo.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                          color:
                              todo.completed ? Colors.black54 : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 메모 (있는 경우에만 표시)
                      if (todo.memo != null && todo.memo!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            todo.memo!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      const SizedBox(height: 8),

                      // 하단 정보 (마감일, 태그, 삭제 버튼)
                      Row(
                        children: [
                          // 개선된 마감일 (기간 있는 할 일)
                          if (todo.hasDeadline && todo.deadline != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: NeumorphicStyles.secondaryButtonColor
                                    .withValues(alpha: 38),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: NeumorphicStyles.secondaryButtonColor
                                      .withValues(alpha: 77),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.event,
                                    size: 12,
                                    color:
                                        NeumorphicStyles.secondaryButtonColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MM/dd').format(todo.deadline!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          NeumorphicStyles.secondaryButtonColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(width: 8),

                          // 태그 개선
                          if (todo.tags.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: NeumorphicStyles.primaryButtonColor
                                    .withValues(alpha: 38),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: NeumorphicStyles.primaryButtonColor
                                      .withValues(alpha: 77),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '#${todo.tags.first}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: NeumorphicStyles.primaryButtonColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          // 추가 태그 개수 표시 개선
                          if (todo.tags.length > 1)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: NeumorphicStyles.primaryButtonColor
                                    .withValues(alpha: 26),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${todo.tags.length - 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: NeumorphicStyles.primaryButtonColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          const Spacer(),

                          // 생성 시간 개선
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 26),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_filled,
                                  size: 10,
                                  color: NeumorphicStyles.textLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getTimeString(todo.createdAt),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: NeumorphicStyles.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 삭제 버튼 개선
                NeumorphicButton(
                  onPressed: onDelete,
                  width: 32,
                  height: 32,
                  padding: EdgeInsets.zero,
                  borderRadius: 16,
                  color: NeumorphicStyles.backgroundColor,
                  child: Center(
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 생성 시간 표시 형식 계산
  String _getTimeString(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (createdDate == today) {
      // 오늘 생성된 항목은 시간만 표시
      return DateFormat('HH:mm').format(dateTime);
    } else {
      // 그 외는 날짜만 표시
      return DateFormat('MM/dd').format(dateTime);
    }
  }
}
