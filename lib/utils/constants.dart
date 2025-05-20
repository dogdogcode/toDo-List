import 'package:flutter/material.dart';

class AppConstants {
  // 한국 공휴일 목록 (2025년)
  static const Map<DateTime, List<String>> koreanHolidays = {
    // DateTime(2025, 1, 1): ['신정'],
    // DateTime(2025, 2, 1): ['설날'],
    // DateTime(2025, 3, 1): ['삼일절'],
    // DateTime(2025, 5, 5): ['어린이날'],
    // DateTime(2025, 5, 27): ['부처님오신날'],
    // DateTime(2025, 6, 6): ['현충일'],
    // DateTime(2025, 8, 15): ['광복절'],
    // DateTime(2025, 9, 19): ['추석'],
    // DateTime(2025, 10, 3): ['개천절'],
    // DateTime(2025, 10, 9): ['한글날'],
    // DateTime(2025, 12, 25): ['크리스마스'],
  };

  // 상수화하여 불필요한 객체 생성 방지
  static const double appBarExpandedHeight = 190.0;
  static const double appBarCollapsedHeight = 80.0;
  static const double bottomNavHeight = 95.0;
  
  // 애니메이션 지속시간을 상수로 관리
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration buttonAnimationDuration = Duration(milliseconds: 150);
}