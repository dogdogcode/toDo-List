import 'package:flutter/material.dart';
import '../utils/neumorphic_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // dummy 계정 정보 사용 (계정 서비스 관련 부분 제거)
    const String username = '게스트 사용자';
    return Scaffold(
      backgroundColor: NeumorphicStyles.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // 헤더 개선
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NeumorphicContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
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
                              color: Colors.black.withAlpha(26),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.white.withAlpha(128),
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
                        children: [
                          const Text(
                            '프로필',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: NeumorphicStyles.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
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
              const SizedBox(height: 40),
              // 개선된 아바타 섹션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NeumorphicContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 20,
                  child: Column(
                    children: [
                      // 사용자 아바타
                      NeumorphicContainer(
                        height: 120,
                        width: 120,
                        borderRadius: 60,
                        padding: EdgeInsets.zero,
                        color: Colors.white,
                        child: const CircleAvatar(
                          radius: 55,
                          backgroundColor:
                              NeumorphicStyles.secondaryButtonColor,
                          child: Icon(
                            Icons.person_rounded,
                            size: 72,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 사용자 이름
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: NeumorphicStyles.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: NeumorphicStyles.secondaryButtonColor
                                .withAlpha(77),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: NeumorphicStyles.secondaryButtonColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 20,
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
              const SizedBox(height: 40),
              _buildMenuItem(icon: Icons.settings, title: '설정', onTap: () {}),
              const SizedBox(height: 16),
              _buildMenuItem(icon: Icons.help, title: '도움말', onTap: () {}),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: Icons.logout,
                title: '로그아웃',
                onTap: () {},
                isLogout: true,
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: NeumorphicButton(
        onPressed: onTap,
        height: 65,
        borderRadius: 20,
        // intensity 매개변수 제거됨
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // 아이콘 부분
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(38),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withAlpha(77), width: 1.5),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            // 제목 부분
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const Spacer(),
            // 화살표
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: NeumorphicStyles.backgroundColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withAlpha(230),
                    offset: const Offset(-1, -1),
                    blurRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: NeumorphicStyles.textLight,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
