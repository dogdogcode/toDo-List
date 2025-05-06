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

  // 뉴모피즘 돌출 효과 (볼록): 윤곽선을 추가하고 그림자 효과 강화
  static BoxDecoration getNeumorphicElevated({
    Color color = backgroundColor,
    double radius = 16.0,
    double intensity = 0.15,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withAlpha(153), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: lightShadow.withAlpha(204),
          offset: const Offset(-5, -5),
          blurRadius: 15,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: darkShadow.withAlpha(128),
          offset: const Offset(5, 5),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // 뉴모피즘 함몰 효과 (오목): 터치시 반응하는 색상 변화 및 윤곽선 효과 적용
  static BoxDecoration getNeumorphicPressed({
    Color color = backgroundColor,
    double radius = 16.0,
    double intensity = 0.25,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: darkShadow.withAlpha(128), width: 1.5),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withAlpha(235), color],
      ),
      boxShadow: [
        BoxShadow(
          color: darkShadow.withAlpha(153),
          offset: const Offset(2, 2),
          blurRadius: 7,
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
  final EdgeInsetsGeometry? margin; // 새로 추가
  final EdgeInsetsGeometry padding;
  final double width;
  final double height;
  final Color color;
  final double borderRadius;
  final bool isPressed;
  final double intensity;
  final BoxDecoration? decoration; // 새로 추가: 외부 decoration override

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(16.0),
    this.width = double.infinity,
    this.height = 100.0,
    this.color = NeumorphicStyles.backgroundColor,
    this.borderRadius = 16.0,
    this.isPressed = false,
    this.intensity = 0.1,
    this.decoration, // override decoration
  });

  @override
  Widget build(BuildContext context) {
    final BoxDecoration computedDecoration =
        decoration ??
        (isPressed
            ? NeumorphicStyles.getNeumorphicPressed(
              color: color,
              radius: borderRadius,
              intensity: intensity,
            )
            : NeumorphicStyles.getNeumorphicElevated(
              color: color,
              radius: borderRadius,
              intensity: intensity,
            ));
    return Container(
      margin: margin, // 추가
      width: width,
      height: height,
      padding: padding,
      decoration: computedDecoration,
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
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const NeumorphicTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
    this.borderRadius = 16.0,
    this.textStyle,
    this.hintStyle,
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
          hintStyle:
              hintStyle ??
              TextStyle(
                color: NeumorphicStyles.textLight,
                fontSize: 16.0,
                fontStyle: FontStyle.italic,
              ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
        ),
        style:
            textStyle ??
            TextStyle(
              color: NeumorphicStyles.textDark,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
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
