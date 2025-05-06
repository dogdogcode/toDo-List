import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

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
    final darkColor = Color.lerp(cardColor, Colors.black, 0.1)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor.withAlpha(230),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha(204),
            offset: const Offset(-4, -4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(51),
            offset: const Offset(4, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
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
                // 체크박스
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          todo.completed
                              ? darkColor
                              : Colors.white.withValues(alpha: 179),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            todo.completed
                                ? darkColor
                                : Colors.white.withValues(alpha: 230),
                        width: 2,
                      ),
                    ),
                    child:
                        todo.completed
                            ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                            : null,
                  ),
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
                        )
                      else
                        // 기본 설명 텍스트 (메모가 없을 경우)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '세부 설명이 없습니다',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // 하단 정보 (마감일, 태그, 삭제 버튼)
                      Row(
                        children: [
                          // 마감일 (기간 있는 할 일)
                          if (todo.hasDeadline && todo.deadline != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 102),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: darkColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MM/dd').format(todo.deadline!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(width: 8),

                          // 태그 (최대 1개만 표시)
                          if (todo.tags.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: darkColor.withValues(alpha: 26),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#${todo.tags.first}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: darkColor,
                                ),
                              ),
                            ),

                          // 추가 태그 개수 표시
                          if (todo.tags.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                '+${todo.tags.length - 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: darkColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          const Spacer(),

                          // 생성 시간
                          Text(
                            _getTimeString(todo.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 삭제 버튼
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          offset: const Offset(-2, -2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(Icons.close, size: 18, color: darkColor),
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
