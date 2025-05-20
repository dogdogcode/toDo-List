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
    
    // 계산된 색상 값
    final Color lightColor = Color.lerp(cardColor, Colors.white, 0.5)!;
    
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 80, maxHeight: 150),
      child: NeumorphicContainer(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: cardColor.withOpacity(0.94), // 0.94 opacity
        borderRadius: 16,
        intensity: 0.15,
        // height 매개변수 제거 (ConstrainedBox로 높이 제어)
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            splashColor: lightColor,
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
                      color: NeumorphicStyles.backgroundColor,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 콘텐츠 영역: Expanded + ConstrainedBox 조합으로 안정적 크기 보장
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // 최소 공간만 사용
                        children: [
                          // 제목: 고정 높이 없이 자연스러운 크기
                          Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: todo.completed ? TextDecoration.lineThrough : null,
                              color: todo.completed ? Colors.black54 : Colors.black87,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          
                          // 하단 정보 영역과의 간격
                          const SizedBox(height: 4),
                          
                          // 가장 문제가 되던 하단 정보 영역 재구성 - Stack 대신 Row + Wrap 조합
                          SizedBox(
                            height: 20, // 높이 감소
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 왼쪽: 태그 및 날짜 정보 (가로로 넘치면 생략)
                                Expanded(
                                  child: Row(
                                    children: [
                                      // 마감일 (있는 경우)
                                      if (hasDeadline)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 6),
                                          child: _buildDateTag(todo.deadline!),
                                        ),
                                      
                                      // 첫 번째 태그 (있는 경우)
                                      if (hasTags && todo.tags.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: _buildTag(todo.tags.first),
                                        ),
                                        
                                      // 추가 태그 표시 (+N)
                                      if (hasTags && todo.tags.length > 1)
                                        _buildTagCount(todo.tags.length - 1),
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
                  ),
                  
                  // 삭제 버튼
                  const SizedBox(width: 8),
                  NeumorphicButton(
                    onPressed: onDelete,
                    width: 32,
                    height: 32,
                    padding: EdgeInsets.zero,
                    borderRadius: 16,
                    color: NeumorphicStyles.backgroundColor,
                    child: const Center(
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
      ),
    );
  }
  
  // 여러 위젯으로 분리하여 코드 가독성 및 유지보수성 향상
  
  // 날짜 태그 위젯
  Widget _buildDateTag(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: NeumorphicStyles.secondaryButtonColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: NeumorphicStyles.secondaryButtonColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event,
            size: 12,
            color: NeumorphicStyles.secondaryButtonColor,
          ),
          const SizedBox(width: 4),
          Text(
            DateFormat('MM/dd').format(date),
            style: const TextStyle(
              fontSize: 12,
              color: NeumorphicStyles.secondaryButtonColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  // 태그 위젯
  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: NeumorphicStyles.primaryButtonColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: NeumorphicStyles.primaryButtonColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(
          fontSize: 11,
          color: NeumorphicStyles.primaryButtonColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  // 추가 태그 개수 위젯
  Widget _buildTagCount(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: NeumorphicStyles.primaryButtonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '+$count',
        style: const TextStyle(
          fontSize: 10,
          color: NeumorphicStyles.primaryButtonColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // 시간 정보 위젯
  Widget _buildTimeInfo(DateTime time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_filled,
            size: 10,
            color: NeumorphicStyles.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            _getTimeString(time),
            style: const TextStyle(
              fontSize: 10,
              color: NeumorphicStyles.textLight,
            ),
          ),
        ],
      ),
    );
  }
  
  // 시간 표시 형식 계산
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