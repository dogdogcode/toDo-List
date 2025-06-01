import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHelper {
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return '오늘 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateOnly == tomorrow) {
      return '내일 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateOnly == yesterday) {
      return '어제 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateTime.year == now.year) {
      return DateFormat('MM월 dd일 HH:mm').format(dateTime);
    } else {
      return DateFormat('yyyy년 MM월 dd일 HH:mm').format(dateTime);
    }
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '오늘';
    } else if (dateOnly == tomorrow) {
      return '내일';
    } else if (dateOnly == yesterday) {
      return '어제';
    } else if (date.year == now.year) {
      return DateFormat('MM월 dd일').format(date);
    } else {
      return DateFormat('yyyy년 MM월 dd일').format(date);
    }
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly == today;
  }

  static bool isTomorrow(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly == tomorrow;
  }

  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  static Duration timeUntilDue(DateTime dueDate) {
    return dueDate.difference(DateTime.now());
  }

  static String getTimeUntilDueString(DateTime dueDate) {
    final duration = timeUntilDue(dueDate);

    if (duration.isNegative) {
      final overdue = duration.abs();
      if (overdue.inDays > 0) {
        return '${overdue.inDays}일 초과';
      } else if (overdue.inHours > 0) {
        return '${overdue.inHours}시간 초과';
      } else {
        return '${overdue.inMinutes}분 초과';
      }
    } else {
      if (duration.inDays > 0) {
        return '${duration.inDays}일 남음';
      } else if (duration.inHours > 0) {
        return '${duration.inHours}시간 남음';
      } else if (duration.inMinutes > 0) {
        return '${duration.inMinutes}분 남음';
      } else {
        return '곧 마감';
      }
    }
  }

  static DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static TimeOfDay dateTimeToTimeOfDay(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  static String getDayOfWeek(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  static String getMonthName(int month) {
    const months = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];
    return months[month - 1];
  }

  // 생성일로부터 며칠 전인지 계산
  static int getDaysAgo(DateTime createdDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdDay = DateTime(createdDate.year, createdDate.month, createdDate.day);
    return today.difference(createdDay).inDays;
  }

  // 마감일까지 며칠 남았는지 계산 (음수면 초과)
  static int getDaysUntilDue(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDayOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueDayOnly.difference(today).inDays;
  }

  // 생성일 기준 표시 문자열
  static String getCreatedAgoString(DateTime createdDate) {
    final daysAgo = getDaysAgo(createdDate);
    
    if (daysAgo == 0) {
      return '오늘 생성';
    } else if (daysAgo == 1) {
      return '어제 생성';
    } else if (daysAgo < 7) {
      return '$daysAgo일 전 생성';
    } else if (daysAgo < 30) {
      final weeks = (daysAgo / 7).floor();
      return '$weeks주 전 생성';
    } else {
      final months = (daysAgo / 30).floor();
      return '$months개월 전 생성';
    }
  }

  // 마감일 기준 표시 문자열
  static String getDueStatusString(DateTime dueDate) {
    final daysUntil = getDaysUntilDue(dueDate);
    
    if (daysUntil < 0) {
      final overdue = daysUntil.abs();
      if (overdue == 1) {
        return '어제 초과';
      } else {
        return '$overdue일 초과';
      }
    } else if (daysUntil == 0) {
      return '오늘 마감';
    } else if (daysUntil == 1) {
      return '내일 마감';
    } else if (daysUntil <= 7) {
      return '$daysUntil일 남음';
    } else if (daysUntil <= 30) {
      final weeks = (daysUntil / 7).floor();
      return '$weeks주 남음';
    } else {
      final months = (daysUntil / 30).floor();
      return '$months개월 남음';
    }
  }

  // 생성일 기준 색상 반환
  static Color getCreatedAgoColor(DateTime createdDate) {
    final daysAgo = getDaysAgo(createdDate);
    
    if (daysAgo == 0) {
      return Colors.grey.shade600; // 오늘 생성
    } else if (daysAgo <= 3) {
      return Colors.lightBlue.shade400; // 1-3일 전
    } else if (daysAgo <= 7) {
      return Colors.blue.shade500; // 4-7일 전
    } else {
      return Colors.deepPurple.shade400; // 1주일 이상
    }
  }

  // 마감일 기준 색상 반환
  static Color getDueStatusColor(DateTime dueDate, bool isCompleted) {
    if (isCompleted) {
      return Colors.green.shade500; // 완료됨
    }
    
    final daysUntil = getDaysUntilDue(dueDate);
    
    if (daysUntil < 0) {
      return Colors.red.shade600; // 초과
    } else if (daysUntil == 0) {
      return Colors.orange.shade600; // 오늘 마감
    } else if (daysUntil <= 2) {
      return Colors.amber.shade600; // 1-2일 남음
    } else {
      return Colors.blue.shade500; // 3일 이상 남음
    }
  }
}
