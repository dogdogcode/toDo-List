import 'package:flutter/material.dart';
import '../utils/neumorphic_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavHeight = 100.0;  // 네비게이션 바 하단 여백 공간
    
    // dummy 계정 정보 사용 (계정 서비스 관련 부분 제거)
    const String username = '게스트 사용자';
    return Scaffold(
      backgroundColor: NeumorphicStyles.backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // iOS 스타일 스크롤 효과
        padding: EdgeInsets.fromLTRB(16.0, 16.0 + MediaQuery.of(context).padding.top, 16.0, 16.0 + bottomNavHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // 헤더 개선 - IntrinsicHeight로 감싸서 오버플로우 방지
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 20,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // 아이콘 컨테이너 개선
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: NeumorphicStyles.secondaryButtonColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1), // 0.1 opacity
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5), // 0.5 opacity
                              offset: const Offset(-1, -1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 텍스트 섹션
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // 크기 제한
                        children: const [
                          Text(
                            '프로필',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: NeumorphicStyles.textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '사용자 설정을 관리하세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: NeumorphicStyles.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30), // 간격 줄임
            // 개선된 아바타 섹션 - 고정 높이 설정으로 오버플로우 방지
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NeumorphicContainer(
                padding: const EdgeInsets.symmetric(vertical: 15), // 패딩 최적화
                borderRadius: 20,
                // IntrinsicHeight로 감싸서 컬럼이 실제 필요한 만큼만 공간 차지하도록 함
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 높이 제한 추가
                    children: [
                      // 사용자 아바타 - 크기 줄임
                      NeumorphicContainer(
                        height: 85, // 크기 더 줄임
                        width: 85, // 크기 더 줄임
                        borderRadius: 50, // 반지름 조정
                        padding: EdgeInsets.zero,
                        color: Colors.white,
                        child: const CircleAvatar(
                          radius: 40, // 반지름 조정
                          backgroundColor: NeumorphicStyles.secondaryButtonColor,
                          child: Icon(
                            Icons.person_rounded,
                            size: 50, // 아이콘 크기 더 줄임
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12), // 간격 더 줄임
                      // 사용자 이름 - 크기 줄이고 레이아웃 최적화
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10, // 패딩 줄임
                          horizontal: 20, // 패딩 줄임
                        ),
                        decoration: BoxDecoration(
                          color: NeumorphicStyles.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: NeumorphicStyles.secondaryButtonColor
                                .withOpacity(0.3), // 0.3 opacity
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: NeumorphicStyles.secondaryButtonColor,
                              size: 18, // 아이콘 크기 줄임
                            ),
                            const SizedBox(width: 10), // 간격 줄임
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 18, // 폰트 크기 줄임
                                fontWeight: FontWeight.bold,
                                color: NeumorphicStyles.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25), // 간격 줄임
            _buildMenuItem(icon: Icons.settings, title: '설정', onTap: () {}),
            const SizedBox(height: 5), // 간격 더 줄임
            _buildMenuItem(icon: Icons.help, title: '도움말', onTap: () {}),
            const SizedBox(height: 5), // 간격 더 줄임
            _buildMenuItem(
              icon: Icons.logout,
              title: '로그아웃',
              onTap: () {},
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final Color iconColor =
        isLogout ? Colors.redAccent : NeumorphicStyles.primaryButtonColor;
    final Color textColor =
        isLogout ? Colors.redAccent : NeumorphicStyles.textDark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 3,
      ), // 세로 패딩 더 줄임
      child: NeumorphicButton(
        onPressed: onTap,
        height: 45, // 높이 더 줄임
        borderRadius: 16, // 라운드 줄임
        padding: const EdgeInsets.symmetric(horizontal: 16), // 패딩 줄임
        child: Row(
          children: [
            // 아이콘 부분 - 크기 줄임
            Container(
              width: 32, 
              height: 32,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15), // 0.15 opacity
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(icon, color: iconColor),
              ),
            ),
            const SizedBox(width: 12), // 간격 줄임
            // 제목 부분
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            // 화살표 - 크기 줄임
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: NeumorphicStyles.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9), // 0.9 opacity
                    offset: const Offset(-1, -1),
                    blurRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // 0.1 opacity
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: NeumorphicStyles.textLight,
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}