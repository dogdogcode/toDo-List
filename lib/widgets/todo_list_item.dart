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
    // 기본 정보 미리 계산
    final bool hasDeadline = todo.hasDeadline && todo.deadline != null;
    final bool hasTags = todo.tags.isNotEmpty;
    final bool hasMemo = todo.memo != null && todo.memo!.isNotEmpty;

    // 계산된 색상 값 (반투명 효과를 위해 opacity 조정 가능)
    final Color lightColor = Color.lerp(cardColor, Colors.white, 0.5)!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: NeumorphicStyles.getNeumorphicElevated(
        color: cardColor,
        radius: 18,
        intensity: 0.12,
        opacity: 0.88,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onToggle,
          splashColor: lightColor.withOpacity(0.3),
          highlightColor: lightColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // 오버플로우 방지를 위해 ConstrainedBox 사용
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬로 변경
              children: [
                // 체크박스: 상단 정렬 유지
                Padding(
                  padding: const EdgeInsets.only(top: 2.0), // 상단 정렬 미세 조정
                  child: NeumorphicCheckbox(
                    value: todo.completed,
                    onChanged: (_) => onToggle(),
                    color: NeumorphicStyles.backgroundColor, // 배경색과 유사하게
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // 콘텐츠 영역: Flexible로 변경하여 유연성 개선
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 제목 영역
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 50),
                        child: Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            decoration:
                                todo.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                            color:
                                todo.completed
                                    ? Colors.black45
                                    : Colors.black87,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 메모: 있을 경우만 표시, 일관된 여백 유지
                      if (hasMemo) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.memo!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          maxLines: 1, // 메모는 한 줄로 제한하여 간결하게
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // 하단 정보 영역과의 간격
                      if (hasDeadline || hasTags) const SizedBox(height: 8),
                      // 하단 정보 영역 - 오버플로우 방지를 위한 개선
                      if (hasDeadline || hasTags)
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 왼쪽: 태그 및 날짜 정보
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 마감일 (있는 경우)
                                    if (hasDeadline)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: _buildDateTag(todo.deadline!),
                                      ),

                                    // 첫 번째 태그 (있는 경우)
                                    if (hasTags && todo.tags.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 4,
                                        ),
                                        child: _buildTag(todo.tags.first),
                                      ),

                                    // 추가 태그 표시 (+N)
                                    if (hasTags && todo.tags.length > 1)
                                      Padding(
                                        // 추가 태그 개수에도 오른쪽 여백 추가
                                        padding: const EdgeInsets.only(
                                          right: 4,
                                        ),
                                        child: _buildTagCount(
                                          todo.tags.length - 1,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // 오른쪽: 생성 시간 (고정 위치)
                              _buildTimeInfo(todo.createdAt),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // 삭제 버튼
                const SizedBox(width: 8),
                NeumorphicButton(
                  onPressed: onDelete,
                  width: 36, // 버튼 크기 약간 증가
                  height: 36,
                  padding: EdgeInsets.zero,
                  borderRadius: 18, // 반지름도 비율에 맞게
                  color: NeumorphicStyles.backgroundColor, // 배경색과 유사하게
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline,
                      size: 20, // 아이콘 크기 약간 증가
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

  // 여러 위젯으로 분리하여 코드 가독성 및 유지보수성 향상

  // 날짜 태그 위젯
  Widget _buildDateTag(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // 패딩 조정
      decoration: BoxDecoration(
        color: NeumorphicStyles.secondaryButtonColor.withOpacity(0.2), // 투명도 조정
        borderRadius: BorderRadius.circular(8), // 반지름 조정
        border: Border.all(
          color: NeumorphicStyles.secondaryButtonColor.withOpacity(
            0.4,
          ), // 테두리 색상 조정
          width: 1, // 테두리 두께 조정
        ),
      ),
      child: Text(
        DateFormat('MM/dd').format(date),
        style: const TextStyle(
          fontSize: 12, // 폰트 크기 유지 또는 약간 조정
          color: NeumorphicStyles.secondaryButtonColor,
          fontWeight: FontWeight.w600, // 굵기 조정
        ),
      ),
    );
  }

  // 태그 위젯
  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: NeumorphicStyles.primaryButtonColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: NeumorphicStyles.primaryButtonColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11.5, // 폰트 크기 조정
          fontWeight: FontWeight.w500, // 폰트 두께 조정
          color: NeumorphicStyles.primaryButtonColor.withOpacity(
            0.9,
          ), // 텍스트 색상 조정
        ),
      ),
    );
  }

  // 추가 태그 개수 표시 위젯
  Widget _buildTagCount(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // 패딩 조정
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2), // 배경색 변경
        borderRadius: BorderRadius.circular(8), // 반지름 조정
        border: Border.all(
          color: Colors.grey.withOpacity(0.4), // 테두리 색상 변경
          width: 1, // 테두리 두께 조정
        ),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: 11.5, // 폰트 크기 조정
          fontWeight: FontWeight.w500, // 폰트 두께 조정
          color: Colors.grey.shade700, // 텍스트 색상 변경
        ),
      ),
    );
  }

  // 시간 정보 위젯
  Widget _buildTimeInfo(DateTime time) {
    return Text(
      DateFormat('HH:mm').format(time), // 시간 형식 변경 (예: 오후 2:30)
      style: const TextStyle(
        fontSize: 12, // 폰트 크기 조정
        color: Colors.black54, // 텍스트 색상 변경
        fontWeight: FontWeight.w500, // 폰트 두께 추가
      ),
    );
  }
}

// Neumorphic 스타일 체크박스 (커스텀 위젯)
class NeumorphicCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color color; // 체크박스 내부 색상
  final double size; // 체크박스 크기

  const NeumorphicCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.color = Colors.white, // 기본값 설정
    this.size = 24.0, // 기본 크기 설정
  });

  @override
  Widget build(BuildContext context) {
    // 아이콘 색상 결정
    final iconColor =
        value
            ? NeumorphicStyles
                .primaryButtonColor // 체크되었을 때의 색상
            : Colors.grey.withOpacity(0.6); // 체크되지 않았을 때의 색상

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), // 부드러운 전환 효과
        width: size,
        height: size,
        decoration: NeumorphicStyles.getNeumorphicConcave(
          color: color, // 배경색 사용
          radius: size * 0.3, // 반지름을 크기에 비례하도록 설정
          intensity: 0.15, // 약간의 깊이감
          opacity: 0.9, // 약간의 투명도
        ),
        child:
            value
                ? Icon(
                  Icons.check_rounded, //둥근 체크 아이콘
                  size: size * 0.7, // 아이콘 크기를 체크박스에 맞게 조정
                  color: iconColor, // 동적 아이콘 색상
                )
                : null, // 체크되지 않았을 때는 아이콘 없음
      ),
    );
  }
}
