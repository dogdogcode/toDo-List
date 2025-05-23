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

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 80,
        maxHeight: 150,
      ), // 최소/최대 높이 유지
      child: NeumorphicContainer(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: cardColor.withOpacity(0.9), // 반투명 효과 조정 (기존 0.94)
        borderRadius: 16,
        intensity: 0.2, // 뉴모피즘 강도 조정 (기존 0.15)
        // height 매개변수 제거 (ConstrainedBox로 높이 제어)
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            splashColor: lightColor, // 터치 시 밝은 색상 효과
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

                  // 콘텐츠 영역: Expanded + ConstrainedBox 조합으로 안정적 크기 보장
                  Expanded(
                    child: Column(
                      // ConstrainedBox 제거하고 Column으로 직접 제어
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // 내용에 맞게 최소 크기
                      children: [
                        // 제목: 고정 높이 없이 자연스러운 크기
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 17, // 약간 크게
                            fontWeight: FontWeight.bold,
                            decoration:
                                todo.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                            color:
                                todo.completed
                                    ? Colors.black54
                                    : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                        const SizedBox(height: 8), // 하단 정보 영역과의 간격 증가
                        // 가장 문제가 되던 하단 정보 영역 재구성 - Stack 대신 Row + Wrap 조합
                        SizedBox(
                          height: 22, // 높이 약간 증가
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 왼쪽: 태그 및 날짜 정보 (가로로 넘치면 생략 또는 스크롤)
                              Expanded(
                                child: SingleChildScrollView(
                                  // 내용이 길 경우 스크롤 가능하도록
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
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
          ), // 테두리 투명도 조정
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_available, // 아이콘 변경 (좀 더 명확한 아이콘)
            size: 13, // 아이콘 크기 조정
            color: NeumorphicStyles.secondaryButtonColor,
          ),
          const SizedBox(width: 5), // 간격 조정
          Text(
            DateFormat('MM/dd').format(date),
            style: const TextStyle(
              fontSize: 12, // 폰트 크기 유지 또는 약간 조정
              color: NeumorphicStyles.secondaryButtonColor,
              fontWeight: FontWeight.w600, // 굵기 조정
            ),
          ),
        ],
      ),
    );
  }

  // 태그 위젯
  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // 패딩 조정
      decoration: BoxDecoration(
        color: NeumorphicStyles.primaryButtonColor.withOpacity(0.2), // 투명도 조정
        borderRadius: BorderRadius.circular(8), // 반지름 조정
        border: Border.all(
          color: NeumorphicStyles.primaryButtonColor.withOpacity(
            0.4,
          ), // 테두리 투명도 조정
          width: 1,
        ),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(
          fontSize: 11, // 폰트 크기 유지 또는 약간 조정
          color: NeumorphicStyles.primaryButtonColor,
          fontWeight: FontWeight.w600, // 굵기 조정
        ),
        overflow: TextOverflow.ellipsis, // 태그가 길 경우 생략
        maxLines: 1,
      ),
    );
  }

  // 추가 태그 개수 위젯
  Widget _buildTagCount(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // 패딩 조정
      decoration: BoxDecoration(
        color: NeumorphicStyles.primaryButtonColor.withOpacity(0.15), // 투명도 조정
        borderRadius: BorderRadius.circular(6), // 반지름 조정
      ),
      child: Text(
        '+$count',
        style: const TextStyle(
          fontSize: 10, // 폰트 크기 유지
          color: NeumorphicStyles.primaryButtonColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 시간 정보 위젯
  Widget _buildTimeInfo(DateTime time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // 패딩 조정
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15), // 투명도 조정
        borderRadius: BorderRadius.circular(6), // 반지름 조정
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            // 아이콘 변경 (좀 더 명확한 아이콘)
            _isToday(time) ? Icons.access_time : Icons.calendar_today_outlined,
            size: 11, // 아이콘 크기 조정
            color: NeumorphicStyles.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            _getTimeString(time),
            style: const TextStyle(
              fontSize: 10, // 폰트 크기 유지
              color: NeumorphicStyles.textLight,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  // 시간 표시 형식 계산
  String _getTimeString(DateTime dateTime) {
    if (_isToday(dateTime)) {
      // 오늘 생성된 항목은 시간만 표시
      return DateFormat('HH:mm').format(dateTime);
    } else {
      // 그 외는 날짜만 표시
      return DateFormat('MM/dd').format(dateTime);
    }
  }
}
