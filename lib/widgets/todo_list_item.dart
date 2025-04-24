import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

// Color 확장 메서드 - 클래스 외부에 선언해야 합니다
extension ColorBrightness on Color {
  Color withBrightness(double brightness) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness * brightness).clamp(0.0, 1.0))
        .toColor();
  }
}

class TodoListItem extends StatelessWidget {
  // 고정 색상 정의 - 올바른 방식으로 상수 선언
  static const Color transparentWhite = Color(0xB2FFFFFF); // 70% 투명도
  static const Color lightTransparentWhite = Color(0x4DFFFFFF); // 30% 투명도
  static const Color shadowColor = Color(0x19000000); // 10% 불투명도
  static const Color completedTextColor = Color(0x99000000); // 60% 불투명도
  static const Color dateTextColor = Color(0x66000000); // 40% 불투명도
  static const Color tagBackgroundColor = Color(0x1A000000); // 10% 불투명도

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
    // 단순화된 색상 계산
    final darkColor = cardColor.withBrightness(0.9);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: shadowColor, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            splashColor: lightTransparentWhite,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 헤더 (체크박스 + 삭제 버튼)
                  Row(
                    children: [
                      // 체크박스
                      GestureDetector(
                        onTap: onToggle,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color:
                                todo.completed ? darkColor : transparentWhite,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  todo.completed ? darkColor : transparentWhite,
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

                      const Spacer(),

                      // 삭제 버튼
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: lightTransparentWhite,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.close, size: 16, color: darkColor),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 제목
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration:
                          todo.completed ? TextDecoration.lineThrough : null,
                      color: todo.completed ? completedTextColor : darkColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 마감일 표시 (기간 있는 할 일)
                  if (todo.hasDeadline && todo.deadline != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lightTransparentWhite,
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
                              color: dateTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 메모 표시 (있는 경우)
                  if (todo.memo != null && todo.memo!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      todo.memo!,
                      style: TextStyle(fontSize: 12, color: dateTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // 태그 표시 (있는 경우)
                  if (todo.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children:
                          todo.tags
                              .take(2) // 최대 2개까지만 표시
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tagBackgroundColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: darkColor,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],

                  // 생성 시간 표시
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      // 오늘 생성된 항목은 시간만, 그 외는 날짜만 표시
                      _getTimeString(todo.createdAt),
                      style: TextStyle(fontSize: 10, color: dateTextColor),
                    ),
                  ),
                ],
              ),
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
