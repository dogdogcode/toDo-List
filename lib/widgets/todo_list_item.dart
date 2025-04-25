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

  // 색상 대비 개선을 위한 엔드포인트 색상 계산
  Color getTextColor() {
    // 배경색이 밝으면 어두운 텍스트, 어두우면 밝은 텍스트
    final luminance = computeLuminance();
    return luminance > 0.5 ? const Color(0xFF222222) : Colors.white;
  }
}

class TodoListItem extends StatelessWidget {
  // 개선된 색상 값들
  static const Color transparentWhite = Color(0xCCFFFFFF); // 80% 투명도로 더 밝게
  static const Color lightTransparentWhite = Color(0x66FFFFFF); // 40% 투명도
  static const Color shadowColor = Color(0x33000000); // 20% 불투명도로 그림자 강화
  static const Color completedTextColor = Color(0xBB000000); // 73% 불투명도로 더 진하게
  static const Color dateTextColor = Color(0xDD000000); // 87% 불투명도로 더 진하게
  static const Color tagBackgroundColor = Color(0x33000000); // 20% 불투명도로 더 집중되게

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
    // 텍스트 대비를 위한 색상 계산 개선
    final textColor = cardColor.getTextColor(); // 계산된 색상 대비 사용
    final darkColor = Color.lerp(cardColor, Colors.black, 0.7)!; // 더 진한 대비색

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            splashColor: lightTransparentWhite,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0), // 패딩 확대하여 더 여유롭게
              child: Row(
                // 열 방향으로 변경하여 더 넓은 필드를 제공
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 체크박스 (왼쪽)
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 28, // 크기 증가
                      height: 28, // 크기 증가
                      margin: const EdgeInsets.only(right: 16), // 오른쪽 여백 추가
                      decoration: BoxDecoration(
                        color: todo.completed ? darkColor : transparentWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: todo.completed ? darkColor : transparentWhite,
                          width: 2,
                        ),
                      ),
                      child:
                          todo.completed
                              ? const Icon(
                                Icons.check,
                                size: 18, // 아이콘 크기 증가
                                color: Colors.white,
                              )
                              : null,
                    ),
                  ),

                  // 메인 컨텐츠 (가운데)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 제목 - 큰 글자로 변경
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 20, // 글자 크기 크게 증가
                            fontWeight: FontWeight.bold,
                            decoration:
                                todo.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                            color:
                                todo.completed ? completedTextColor : textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3, // 최대 3줄로 제한을 늘려 더 많은 텍스트 표시 가능
                        ),

                        const SizedBox(height: 8),

                        // 마감일 표시 (기간 있는 할 일)
                        if (todo.hasDeadline && todo.deadline != null)
                          Row(
                            children: [
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
                                      size: 14, // 아이콘 크기 증가
                                      color: darkColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat(
                                        'MM/dd',
                                      ).format(todo.deadline!),
                                      style: TextStyle(
                                        fontSize: 16, // 글자 크기 증가
                                        color: dateTextColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 삭제 버튼을 마감일 표시와 한 줄에 배치
                              const Spacer(),
                              GestureDetector(
                                onTap: onDelete,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: lightTransparentWhite,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: darkColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // 메모 표시 (있는 경우)
                        if (todo.memo != null && todo.memo!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              todo.memo!,
                              style: TextStyle(
                                fontSize: 16, // 크기 증가
                                color: textColor,
                                fontWeight: FontWeight.w400, // 조금 더 강조
                              ),
                              maxLines: 2, // 2줄로 확장
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        // 태그 표시 (있는 경우)
                        if (todo.tags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Wrap(
                              spacing: 6, // 간격 넓게
                              runSpacing: 6,
                              children:
                                  todo.tags
                                      .take(2) // 최대 2개까지만 표시
                                      .map(
                                        (tag) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: tagBackgroundColor,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: darkColor.withAlpha(51), // 0.2 투명도를 alpha 값으로 변환 (255 * 0.2 = 51)
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '#$tag',
                                            style: TextStyle(
                                              fontSize: 14, // 크기 증가
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),

                        // 삭제 버튼이 마감일 표시와 같은 줄에 있지 않을 경우 여기에 추가
                        if (!todo.hasDeadline || todo.deadline == null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: onDelete,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: lightTransparentWhite,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: darkColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 생성 시간 표시 (오른쪽 끝부분)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: lightTransparentWhite,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      // 오늘 생성된 항목은 시간만, 그 외는 날짜만 표시
                      _getTimeString(todo.createdAt),
                      style: TextStyle(fontSize: 14, color: textColor), // 크기 증가
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

  // 생성 시간 표시 형식 계산 - 더 명확한 형식으로 개선
  String _getTimeString(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (createdDate == today) {
      // 오늘 생성된 항목은 시간만 표시 (한글 형식으로 개선)
      return '오늘 ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      // 그 외는 날짜를 한글 형식으로 표시
      return DateFormat('MM월 dd일').format(dateTime);
    }
  }
}
