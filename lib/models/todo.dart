// lib/models/todo.dart
// Hive 관련 코드 제거 (part 선언 및 어노테이션)

class Todo {
  String id;
  String title;
  bool completed;
  bool hasDeadline;
  DateTime? deadline;
  String? memo;
  List<String> tags;

  // 추가된 시간 정보
  DateTime createdAt;
  DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    this.completed = false,
    this.hasDeadline = false,
    this.deadline,
    this.memo,
    List<String>? tags,
    DateTime? createdAt,
    this.completedAt,
  }) : tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now();

  // 기간 없는 간단한 할 일 생성을 위한 팩토리 메서드
  factory Todo.simple({required String title}) {
    return Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
  }

  // 기간 있는 상세 할 일 생성을 위한 팩토리 메서드
  factory Todo.detailed({
    required String title,
    DateTime? deadline, // DateTime?으로 변경하여 nullable 허용
    String? memo,
    List<String>? tags,
  }) {
    return Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      hasDeadline: deadline != null, // deadline 유무에 따라 hasDeadline 설정
      deadline: deadline,
      memo: memo,
      tags: tags,
    );
  }

  // 완료 상태 토글 메서드
  void toggleCompleted() {
    completed = !completed;
    // 완료 표시할 때만 완료 시간 기록
    completedAt = completed ? DateTime.now() : null;
  }

  // Todo 객체를 Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'hasDeadline': hasDeadline,
      'deadline': deadline?.toIso8601String(),
      'memo': memo,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Map에서 Todo 객체로 변환하는 팩토리 생성자
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      hasDeadline: json['hasDeadline'] as bool,
      deadline:
          json['deadline'] != null
              ? DateTime.parse(json['deadline'] as String)
              : null,
      memo: json['memo'] as String?,
      tags: List<String>.from(json['tags'] as Iterable<dynamic>? ?? []),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : null,
    );
  }
}
