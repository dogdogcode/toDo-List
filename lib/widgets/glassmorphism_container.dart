import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double blur;
  final double opacity;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const GlassmorphismContainer({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.blur = 25,
    this.opacity = 0.15,
    this.borderColor = Colors.white,
    this.borderWidth = 1.2,
    this.borderRadius = 16,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: GlassmorphicContainer(
        width: width,
        height: height,
        borderRadius: borderRadius,
        blur: blur,
        alignment: Alignment.bottomCenter,
        border: borderWidth,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            borderColor.withOpacity(opacity),
            borderColor.withOpacity(opacity * 0.05),
          ],
          stops: const [0.0, 1.0],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [borderColor.withOpacity(0.3), borderColor.withOpacity(0.1)],
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// 카드 형태의 글래스모피즘 컨테이너
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor; // 이 색상을 기반으로 그라데이션 생성
  final double? height;

  const GlassCard({
    Key? key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.borderRadius = 24, // 기본 borderRadius 증가
    this.backgroundColor,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: (backgroundColor ?? theme.primaryColor).withOpacity(0.1),
          highlightColor: (backgroundColor ?? theme.primaryColor).withOpacity(
            0.05,
          ),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    backgroundColor != null
                        ? [
                          backgroundColor!.withOpacity(
                            isDark ? 0.25 : 0.45,
                          ), // 투명도 조정
                          backgroundColor!.withOpacity(
                            isDark ? 0.10 : 0.20,
                          ), // 투명도 조정
                        ]
                        : isDark
                        ? [
                          Colors.white.withOpacity(0.12), // 어두운 테마 글래스 효과 강화
                          Colors.white.withOpacity(0.05),
                        ]
                        : [
                          Colors.white.withOpacity(0.85), // 밝은 테마 글래스 효과 강화
                          Colors.white.withOpacity(0.50),
                        ],
                stops: const [0.0, 1.0],
              ),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.2) // 테두리 강화
                        : Colors.white.withOpacity(0.6), // 테두리 강화
                width: 1.5, // 테두리 두께 증가
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    isDark ? 0.25 : 0.12,
                  ), // 그림자 강화
                  blurRadius: 35, // 블러 반경 증가
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                // 내부 하이라이트 효과 (선택적)
                BoxShadow(
                  color: (backgroundColor ?? Colors.white).withOpacity(
                    isDark ? 0.08 : 0.3,
                  ),
                  blurRadius: 20,
                  spreadRadius: -10, // 안쪽으로 더 깊게
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              // BackdropFilter를 위해 ClipRRect 추가
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                // 블러 효과 추가
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 앱바용 글래스모피즘 컨테이너
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const GlassAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      // 블러 효과를 위해 ClipRRect 추가
      child: BackdropFilter(
        // 블러 효과 추가
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDark
                      ? [
                        Colors.black.withOpacity(0.4), // 투명도 조정
                        Colors.black.withOpacity(0.2), // 투명도 조정
                      ]
                      : [
                        Colors.white.withOpacity(0.7), // 투명도 조정
                        Colors.white.withOpacity(0.5), // 투명도 조정
                      ],
            ),
          ),
          child: AppBar(
            title: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            centerTitle: centerTitle,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: leading,
            actions: actions,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
