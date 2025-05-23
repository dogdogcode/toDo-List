import 'package:flutter/material.dart';
import '../utils/neumorphic_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bottomNavHeight = 100.0;

    const String username = '게스트 사용자';
    return Scaffold(
      backgroundColor: NeumorphicStyles.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NeumorphicStyles.backgroundColor.withOpacity(0.98),
              NeumorphicStyles.backgroundColor.withOpacity(0.94),
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16.0,
            16.0 + MediaQuery.of(context).padding.top,
            16.0,
            16.0 + bottomNavHeight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: NeumorphicStyles.getNeumorphicElevated(
                    color: NeumorphicStyles.backgroundColor,
                    radius: 20,
                    intensity: 0.1,
                    opacity: 0.92,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: NeumorphicStyles.secondaryButtonColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NeumorphicContainer(
                  height: 180, // 충분한 높이 지정
                  width: double.infinity, // 전체 너비 사용
                  color: NeumorphicStyles.backgroundColor.withOpacity(
                    0.8,
                  ), // 반투명 뉴모피즘 배경
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  borderRadius: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const NeumorphicContainer(
                        height: 85,
                        width: 85,
                        borderRadius: 50,
                        padding: EdgeInsets.zero,
                        color: Colors.white,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              NeumorphicStyles.secondaryButtonColor,
                          child: Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: NeumorphicStyles.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: NeumorphicStyles.secondaryButtonColor
                                .withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: NeumorphicStyles.secondaryButtonColor,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 18,
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
              const SizedBox(height: 25),
              _buildMenuItem(icon: Icons.settings, title: '설정', onTap: () {}),
              const SizedBox(height: 5),
              _buildMenuItem(icon: Icons.help, title: '도움말', onTap: () {}),
              const SizedBox(height: 5),
              _buildMenuItem(
                icon: Icons.logout,
                title: '로그아웃',
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('로그아웃'),
                        content: const Text('정말로 로그아웃 하시겠습니까?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('취소'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('로그아웃'),
                            onPressed: () {
                              // TODO: 실제 로그아웃 로직 구현
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                isLogout: true,
              ),
            ], // Column children
          ), // Column
        ), // SingleChildScrollView
      ), // Container
    ); // Scaffold
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: NeumorphicButton(
        onPressed: onTap,
        height: 45,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: iconColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(icon, color: iconColor),
              ),
            ),
            const SizedBox(width: 12),
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
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: textColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
