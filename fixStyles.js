// 이 파일은 모든 withValues() 메서드를 withOpacity()로 변환하는 스크립트입니다.
// Flutter 앱에서 브라우저와 iOS 간의 렌더링 차이를 해결합니다.

function fixCode(code) {
  // withValues(alpha: X) 를 withOpacity(X/255)로 변환
  return code.replace(/\.withValues\(\s*alpha:\s*(\d+)\s*\)/g, (match, alpha) => {
    const opacity = Number(alpha) / 255;
    return `.withOpacity(${opacity.toFixed(2)})`;
  });
}

// 예시:
// color: Colors.black.withValues(alpha: 38) -> color: Colors.black.withOpacity(0.15)
