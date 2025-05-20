# 뉴모피즘 Todo 앱

Flutter로 개발된 현대적인 뉴모피즘 디자인의 Todo 앱입니다. 직관적인 UI와 실용적인 기능을 제공합니다.

## 주요 기능

### 할 일 관리
- 간단한 할 일 추가
- 상세 할 일 추가 (마감일, 메모, 태그 포함)
- 할 일 완료 표시
- 할 일 삭제
- 생성 시간 표시

### 일정 관리
- 캘린더 보기
- 날짜별 할 일 목록
- 공휴일 표시
- 당일 일정 빠른 확인

### 디자인
- 뉴모피즘 디자인 적용
- 부드러운 애니메이션
- 밝고 현대적인 색상 테마
- 사용자 친화적인 인터페이스

## 기술 스택

### 프론트엔드
- Flutter: 크로스 플랫폼 UI 프레임워크
- Provider: 상태 관리
- Table Calendar: 캘린더 기능 구현

### 데이터 관리
- 로컬 스토리지 활용
- JSON 변환 로직 구현

## 프로젝트 구조

```
lib/
├── main.dart               # 앱 진입점
├── models/                 # 데이터 모델
│   └── todo.dart           # Todo 데이터 모델
├── providers/              # 상태 관리
│   └── todo_provider.dart  # Todo 상태 관리
├── screens/                # 화면 UI
│   ├── calendar_screen.dart   # 캘린더 화면
│   ├── todo_list_screen.dart  # 할일 목록 화면
│   └── profile_screen.dart    # 프로필 화면
├── services/               # 비즈니스 로직
│   └── account_service.dart   # 계정 관련 서비스
├── utils/                  # 유틸리티
│   ├── constants.dart      # 앱 전역 상수
│   └── neumorphic_styles.dart # 뉴모피즘 스타일 정의
└── widgets/                # 재사용 가능한 위젯
    ├── todo_list_item.dart     # 할일 목록 아이템
    └── detailed_todo_input.dart # 상세 할일 입력 화면
```

## UI 구성 요소

### 뉴모피즘 스타일 컴포넌트
- NeumorphicContainer: 뉴모피즘 컨테이너
- NeumorphicButton: 뉴모피즘 버튼
- NeumorphicTextField: 뉴모피즘 텍스트 필드
- NeumorphicCheckbox: 뉴모피즘 체크박스

### 화면
1. **할일 목록 화면**: 할일 목록 보기, 추가, 삭제
2. **캘린더 화면**: 날짜별 할일 보기
3. **프로필 화면**: 사용자 설정 및 통계

## 주요 코드 설명

### Todo 모델
할일 데이터 모델로 제목, 완료 상태, 마감일, 메모, 태그 등의 속성을 포함합니다.

### 뉴모피즘 스타일
모던하고 부드러운 디자인을 제공하기 위한 특별한 스타일 정의. 볼록한 효과와 오목한 효과를 상황에 맞게 적용합니다.

### 상태 관리
Provider 패턴을 사용하여 앱 전체 상태를 효율적으로 관리합니다.

## 향후 계획

- [ ] 다크 모드 지원
- [ ] 알림 기능 추가
- [ ] 반복 일정 지원
- [ ] 데이터 동기화 (클라우드)
- [ ] 통계 및 성취도 시각화
- [ ] 다국어 지원