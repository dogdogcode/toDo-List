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
}
