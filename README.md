# 뉴모피즘 Todo 앱 (반투명 UI)

Flutter로 개발된 현대적인 뉴모피즘과 반투명 UI를 결합한 Todo 앱입니다. 직관적인 UI와 실용적인 기능을 제공하며, 모든 연령대가 사용하기 쉽도록 단순한 UX를 지향합니다.

## 주요 기능

### 할 일 관리

- 간단한 할 일 추가 (제목, 설명, 중요도, 마감일)
- 할 일 목록 보기 (진행중, 완료됨 구분)
- 할 일 완료/미완료 토글
- 할 일 삭제 (스와이프)
- 생성 시간 및 마감일 표시
- 중요 할 일 표시

### 화면 구성

- **홈 화면**: 시간대별 인사말, 오늘의 진행률, 중요한 할 일 요약, 오늘의 목표(예시)
- **할 일 목록 화면**: 전체 할 일 목록, 필터(완료 여부), 정렬(생성일, 마감일) 기능
- 플로팅 액션 버튼(+)으로 빠른 할 일 추가

### 디자인

- 뉴모피즘 디자인과 반투명 글래스 효과 결합
- 부드러운 애니메이션 (단계적으로 적용 예정)
- 밝고 현대적인 색상 테마 (노란색 제외, 파란색 계열 Accent)
- 사용자 친화적이고 단순한 인터페이스
- 시니어 모드 UI 고려 (폰트 크기, 터치 영역 등 `AppStyles`에 변수 정의)

## 기술 스택

### 프론트엔드

- Flutter: 크로스 플랫폼 UI 프레임워크

### 데이터 관리

- `shared_preferences`: 로컬 스토리지 활용 (JSON 변환)

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   └── task.dart             # Task 데이터 모델
├── screens/                  # 화면 UI
│   ├── home_screen.dart      # 홈 화면
│   └── task_list_screen.dart # 할일 목록 화면
├── services/                 # 비즈니스 로직
│   └── local_storage_service.dart # 로컬 저장소 서비스
├── utils/                    # 유틸리티
│   ├── app_colors.dart       # 앱 색상 정의
│   ├── app_styles.dart       # 앱 스타일 (폰트, 패딩, 시니어 모드 등)
│   ├── constants.dart        # 앱 전역 상수 (애니메이션 등)
│   └── time_helper.dart      # 시간 관련 유틸리티
└── widgets/                  # 재사용 가능한 위젯
    ├── frosted_glass_effect.dart # 반투명 효과 위젯
    ├── neumorphic_elements.dart  # 뉴모피즘 UI 요소 (컨테이너, 버튼)
    ├── task_item.dart          # 할일 목록 아이템 위젯
    ├── task_progress_indicator.dart # 진행률 표시 위젯
    └── add_task_dialog.dart    # 할일 추가 다이얼로그
```

## UI 구성 요소

### 핵심 스타일 컴포넌트

- `NeumorphicContainer`: 뉴모피즘 컨테이너
- `NeumorphicButton`: 뉴모피즘 버튼
- `FrostedGlassEffect`: 반투명 글래스 효과 컨테이너

### 화면

1. **홈 화면**: 오늘의 요약 및 빠른 접근
2. **할일 목록 화면**: 전체 할일 관리 (필터, 정렬)

## 주요 코드 설명

### Task 모델

할일 데이터 모델로 ID, 제목, 설명, 완료 상태, 중요도, 마감일, 태그(예정), 생성/수정일, 순서 등을 포함합니다. `fromJson`, `toJson` 메서드를 통해 로컬 저장소를 지원합니다.

### 뉴모피즘 및 반투명 스타일

`neumorphic_elements.dart`와 `frosted_glass_effect.dart`를 통해 앱의 주요 시각적 스타일을 구현합니다. `AppColors`와 `AppStyles`에서 색상과 스타일 가이드라인을 관리합니다.

### 로컬 데이터 저장

`LocalStorageService` 클래스가 `shared_preferences`를 사용하여 할일 데이터를 JSON 형태로 기기에 저장하고 불러옵니다.

## 향후 계획 (개발 내용.md 참고)

- [ ] CRUD 기능 완성 (수정, 드래그앤드롭 순서 변경)
- [ ] 스와이프로 완료 기능
- [ ] 달력 뷰 및 날짜별 할일 연동
- [ ] 태그 기능 및 필터링
- [ ] 알림 기능 추가
- [ ] 반복 일정 지원
- [ ] 애니메이션 시스템 구체화
- [ ] 시니어 모드 UI 완전 적용 및 테스트
- [ ] 다크 모드 지원
- [ ] 통계 및 성취도 시각화
- [ ] (선택) 데이터 동기화 (클라우드)
- [ ] (선택) 다국어 지원
