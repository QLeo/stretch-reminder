# 🤸 Stretch Reminder

건강한 업무 습관을 위한 macOS 스트레칭 알림 앱입니다.

## 소개

Stretch Reminder는 장시간 앉아서 일하는 분들을 위한 간편한 메뉴바 앱입니다. 설정한 시간마다 스트레칭을 권장하는 전체화면 알림을 표시하여, 건강한 업무 습관을 유지할 수 있도록 도와줍니다.

## 주요 기능

- **메뉴바 통합**: 독(Dock)에 표시되지 않고 메뉴바에만 상주하는 깔끔한 인터페이스
- **유연한 타이머 설정**:
  - 빠른 선택: 20분, 40분, 50분 프리셋
  - 커스텀 설정: 1~999분 범위에서 자유롭게 설정
- **시각적 피드백**:
  - 원형 프로그레스 링으로 남은 시간 표시
  - 타이머 상태를 한눈에 확인 (실행중/일시정지/정지)
- **전체화면 알림**: 시간이 되면 화면 전체에 알림 표시
- **간편한 제어**:
  - 시작/일시정지/정지 기능
  - ESC 또는 스페이스바로 알림 닫기
  - 모든 가상 데스크탑에서 작동
- **설정 저장**: 선택한 타이머 설정이 자동으로 저장됨

## 시스템 요구사항

- macOS 12.0 (Monterey) 이상
- Apple Silicon 또는 Intel Mac

## 설치 방법

### 소스에서 빌드

1. 저장소 클론:
```bash
git clone https://github.com/yourusername/stretch-reminder.git
cd stretch-reminder
```

2. 앱 빌드:
```bash
./build-app.sh
```

3. 앱 실행:
```bash
open build/StretchReminder.app
```

4. (선택사항) 응용 프로그램 폴더에 설치:
```bash
cp -r build/StretchReminder.app /Applications/
```

## 사용 방법

### 기본 사용

1. **앱 실행**: StretchReminder를 실행하면 메뉴바에 🙋 아이콘이 나타납니다
2. **설정 열기**: 메뉴바 아이콘을 클릭하면 타이머 설정 창이 열립니다
3. **타이머 설정**:
   - 빠른 선택 버튼(20분, 40분, 50분) 중 하나를 선택하거나
   - "Custom"을 선택하여 원하는 시간을 직접 입력
4. **타이머 시작**: "Start" 버튼을 클릭하여 타이머 시작
5. **알림 확인**: 설정한 시간이 지나면 전체화면 알림이 표시됩니다

### 타이머 제어

- **시작**: Start 버튼으로 타이머 시작
- **일시정지**: Pause 버튼으로 타이머 일시정지
- **재개**: Resume 버튼으로 일시정지된 타이머 재개
- **정지**: Stop 버튼으로 타이머 정지 및 초기화

### 알림 닫기

스트레칭 알림이 표시되면:
- **ESC 키** 또는 **스페이스바**를 눌러 닫기
- 화면을 클릭하여 닫기
- "OK" 버튼을 클릭하여 닫기

알림을 닫으면 타이머가 자동으로 재시작됩니다.

## 개발

### 빌드

```bash
# 개발 빌드
swift build

# 릴리스 빌드
swift build -c release

# 앱 번들 생성
./build-app.sh
```

### 프로젝트 구조

```
Sources/StretchReminder/
├── StretchReminder.swift          # 앱 진입점
├── AppDelegate.swift              # 앱 델리게이트 (메뉴바, 타이머 관리)
├── Models/
│   └── TimerManager.swift         # 타이머 로직 및 상태 관리
├── Views/
│   └── SettingsView.swift         # 설정 UI (SwiftUI)
└── Utilities/
    └── BreakReminderWindow.swift  # 전체화면 알림 창
```

### 기술 스택

- **언어**: Swift 5.9+
- **UI 프레임워크**: SwiftUI + AppKit
- **빌드 시스템**: Swift Package Manager
- **의존성**: 없음 (순수 Swift 표준 라이브러리)

## 라이선스

이 프로젝트는 개인 프로젝트입니다.

## 기여

개선 사항이나 버그 리포트는 이슈로 남겨주세요!

---

**건강하게 일하세요! 💪**
