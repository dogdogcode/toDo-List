import 'package:flutter/material.dart';

class NeumorphicStyles {
  // 앱 전체 색상 테마
  static const Color backgroundColor = Color(0xFFF5F8FF); // 약간 푸른 빛이 도는 밝은 배경
  static const Color lightShadow = Color(0xFFFFFFFF);
  static const Color darkShadow = Color(0xFFA3B1C6);

  // 카드 색상들 - 더 부드러운 톤으로 변경
  static const List<Color> cardColors = [
    Color(0xFFFFE0B2), // 연한 주황
    Color(0xFFBBDEFB), // 연한 파랑
    Color(0xFFFFCDD2), // 연한 빨강
    Color(0xFFC5CAE9), // 연한 인디고
    Color(0xFFDCEDC8), // 연한 그린
    Color(0xFFFFE0B2), // 연한 호박색
    Color(0xFFF8BBD0), // 연한 핑크
    Color(0xFFD1C4E9), // 연한 보라
  ];

  // 버튼 색상
  static const Color primaryButtonColor = Color(0xFFFFC107); // 노란색
  static const Color secondaryButtonColor = Color(0xFF42A5F5); // 파랑색

  // 텍스트 색상
  static const Color textDark = Color(0xFF2D3748);
  static const Color textLight = Color(0xFF718096);

  // 뉴모피즘 돌출 효과 (볼록)
  static BoxDecoration getNeumorphicElevated({
    Color color = backgroundColor,
    double radius = 16.0,
    double intensity = 0.1,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Color.fromARGB(
            (255 * intensity).toInt(),
            163, // darkShadow.red
            177, // darkShadow.green
            198, // darkShadow.blue
          ),
          offset: const Offset(5, 5),
          blurRadius: 15,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Color.fromARGB(
            (255 * (intensity + 0.05)).round(),
            255, // lightShadow.red
            255, // lightShadow.green
            255, // lightShadow.blue
          ),
          offset: const Offset(-5, -5),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // 뉴모피즘 함몰 효과 (오목) - inset 속성 제거
  static BoxDecoration getNeumorphicPressed({
    Color color = backgroundColor,
    double radius = 16.0,
    double intensity = 0.25,
  }) {
    // Flutter에서는 BoxShadow에 inset 속성이 없으므로 대안으로
    // InnerShadow 효과를 내기 위해 다른 방식으로 구현합니다.
    // 어두운 색상의 그라디언트를 사용합니다.
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      gradient: RadialGradient(
        // backgroundColor 고정값: R=245, G=248, B=255
        colors: [Color.fromRGBO(245, 248, 255, 242 / 255), color],
        center: Alignment.center,
        focal: Alignment.center,
        radius: 2.0,
        focalRadius: 0.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(
            163, // darkShadow.red
            177, // darkShadow.green
            198, // darkShadow.blue
            (255 * intensity / 3).round() / 255,
          ),
          offset: const Offset(2, 2),
          blurRadius: 5,
          spreadRadius: 0,
        ),
      ],
    );
  }

  // 새로 추가: 플로팅 액션 버튼 꾸밈 헬퍼 메서드
  static BoxDecoration getFABDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          primaryButtonColor,
          primaryButtonColor.withAlpha(204), // 여기도 필요시 255,193,7에 직접 값 넣을 수 있음
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: primaryButtonColor.withAlpha(76), // withAlpha 사용
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // 랜덤 카드 색상 얻기
  static Color getRandomCardColor() {
    return cardColors[DateTime.now().millisecondsSinceEpoch %
        cardColors.length];
  }
}

// 기본 뉴모픽 컨테이너 위젯
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double width;
  final double height;
  final Color color;
  final double borderRadius;
  final bool isPressed;
  final double intensity;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.width = double.infinity,
    this.height = 100.0,
    this.color = NeumorphicStyles.backgroundColor,
    this.borderRadius = 16.0,
    this.isPressed = false,
    this.intensity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration:
          isPressed
              ? NeumorphicStyles.getNeumorphicPressed(
                color: color,
                radius: borderRadius,
                intensity: intensity,
              )
              : NeumorphicStyles.getNeumorphicElevated(
                color: color,
                radius: borderRadius,
                intensity: intensity,
              ),
      child: child,
    );
  }
}

// 뉴모픽 버튼
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final double borderRadius;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = NeumorphicStyles.backgroundColor,
    this.borderRadius = 16.0,
    this.width = double.infinity,
    this.height = 50.0,
    this.padding = const EdgeInsets.all(12.0),
  });

  @override
  NeumorphicButtonState createState() => NeumorphicButtonState();
}

class NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration:
            _isPressed
                ? NeumorphicStyles.getNeumorphicPressed(
                  color: widget.color,
                  radius: widget.borderRadius,
                )
                : NeumorphicStyles.getNeumorphicElevated(
                  color: widget.color,
                  radius: widget.borderRadius,
                ),
        child: widget.child,
      ),
    );
  }
}

// 뉴모픽 텍스트 필드
class NeumorphicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onSubmitted;
  final double borderRadius;

  const NeumorphicTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeumorphicStyles.getNeumorphicPressed(
        radius: borderRadius,
        intensity: 0.08,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
        ),
        style: TextStyle(color: NeumorphicStyles.textDark, fontSize: 16.0),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

// 뉴모픽 체크박스
class NeumorphicCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;
  final double size;

  const NeumorphicCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.color = NeumorphicStyles.backgroundColor,
    this.size = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: size,
        height: size,
        decoration:
            value
                ? BoxDecoration(
                  color: NeumorphicStyles.primaryButtonColor,
                  borderRadius: BorderRadius.circular(size / 3),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(
                        163, // darkShadow.red
                        177, // darkShadow.green
                        198, // darkShadow.blue
                        76 / 255,
                      ),
                      offset: const Offset(2, 2),
                      blurRadius: 5,
                    ),
                  ],
                )
                : NeumorphicStyles.getNeumorphicElevated(
                  color: color,
                  radius: size / 3,
                ),
        child:
            value
                ? const Icon(Icons.check, color: Colors.white, size: 16.0)
                : null,
      ),
    );
  }
}
