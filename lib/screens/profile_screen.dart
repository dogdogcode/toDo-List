import 'package:flutter/material.dart';
import '../utils/neumorphic_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicStyles.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // 프로필 헤더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: NeumorphicStyles.secondaryButtonColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '프로필',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicStyles.textDark,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 42),
                          child: Text(
                            '사용자 설정을 관리하세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: NeumorphicStyles.textLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // 프로필 이미지
              NeumorphicContainer(
                height: 120,
                width: 120,
                borderRadius: 60,
                padding: EdgeInsets.zero,
                child: const CircleAvatar(
                  radius: 60,
                  backgroundColor: NeumorphicStyles.secondaryButtonColor,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 사용자 이름
              NeumorphicContainer(
                height: 56,
                width: double.infinity,
                child: const Center(
                  child: Text(
                    '사용자 이름',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: NeumorphicStyles.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 메뉴 아이템들
              _buildMenuItem(
                icon: Icons.settings,
                title: '설정',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: Icons.help,
                title: '도움말',
                onTap: () {},
              ),
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
    return NeumorphicButton(
      onPressed: onTap,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLogout 
                  ? Colors.red.withOpacity(0.1)
                  : NeumorphicStyles.primaryButtonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isLogout 
                  ? Colors.red
                  : NeumorphicStyles.primaryButtonColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isLogout 
                  ? Colors.red
                  : NeumorphicStyles.textDark,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right,
            color: NeumorphicStyles.textLight,
          ),
        ],
      ),
    );
  }
}
