# CLAUDE.md

이 파일은 Claude Code (claude.ai/code)가 이 저장소의 코드 작업 시 참고할 가이드를 제공합니다.

## 프로젝트 개요

TSCalendar는 iOS 15+ 용 SwiftUI 달력 라이브러리로, 유연한 설정 옵션을 제공하는 커스터마이징 가능한 달력 뷰를 제공합니다. SwiftUI와 UIKit 구현을 모두 지원하며 위젯도 지원합니다.

## 아키텍처

### 핵심 구조

- **Sources/Public/**: 메인 API 클래스 및 공개 인터페이스
  - `TSCalendar.swift` - 메인 SwiftUI 뷰 컴포넌트
  - `TSCalendarUIView.swift` - UIKit 래퍼
  - `TSCalendarConfig.swift` - 반응형 프로퍼티를 가진 설정 객체
  - `TSCalendarAppearance.swift` - 외관 및 스타일링 시스템
  - `TSCalendarEnums.swift` - 공개 열거형 및 타입
  - `TSCalendarProtocols.swift` - Delegate 및 DataSource 프로토콜

- **Sources/Internal/**: 구현 세부사항
  - `Views/Calendar/` - 핵심 달력 뷰 구현
  - `Views/ViewModels/` - MVVM 뷰 모델 레이어
  - `Extensions/` - 내부용 Swift 확장

### 주요 컴포넌트

1. **TSCalendar** - TSCalendarViewModel과 함께 StateObject 패턴을 사용하는 메인 SwiftUI 뷰
2. **TSCalendarConfig** - 반응형 업데이트를 위한 Combine 퍼블리셔로 달력 설정을 관리하는 ObservableObject
3. **TSCalendarAppearance** - 앱 및 위젯 컨텍스트를 지원하는 스타일링 처리
4. **TSCalendarViewModel** - 달력 상태, 날짜 선택, delegate/dataSource 조정 관리

### 설정 시스템

라이브러리는 `TSCalendarConfig`가 Combine을 통해 변경사항을 발행하는 반응형 설정 시스템을 사용합니다. 설정이 변경되면 메인 뷰는 설정 프로퍼티로부터 계산된 `id`를 사용하여 재구성됩니다.

## 빌드 명령어

### Swift Package Manager
```bash
swift build                    # 패키지 빌드
swift test                     # 테스트 실행 (가능한 경우)
swift package resolve         # 의존성 해결
```

### Xcode 프로젝트 (예제)
```bash
# SwiftUI 데모
open Examples/TSCalendarSwiftUIDemo/TSCalendarSwiftUIDemo.xcodeproj
xcodebuild -project Examples/TSCalendarSwiftUIDemo/TSCalendarSwiftUIDemo.xcodeproj -scheme TSCalendarSwiftUIDemo

# UIKit 데모
open Examples/TSCalendarUIKitDemo/TSCalendarUIKitDemo.xcodeproj
xcodebuild -project Examples/TSCalendarUIKitDemo/TSCalendarUIKitDemo.xcodeproj -scheme TSCalendarUIKitDemo
```

## 개발 노트

- **플랫폼**: iOS 15.0+, Swift 6.0+
- **아키텍처**: SwiftUI/Combine을 사용한 MVVM
- **위젯 지원**: 크기별 외관을 가진 위젯 확장 포함
- **지역화**: 국제 지원을 위해 Locale.current와 함께 DateFormatter 사용
- **상태 관리**: @StateObject, @ObservedObject, @Published 프로퍼티 사용
- **반응형 업데이트**: Combine 퍼블리셔를 통한 설정 변경이 뷰 재구성 트리거

## 주요 열거형

- `TSCalendarDisplayMode`: `.month` 또는 `.week` 뷰 모드
- `TSCalendarHeightStyle`: `.flexible` 또는 `.fixed(CGFloat)` 높이 옵션
- `TSCalendarMonthStyle`: `.dynamic` (가변 주) 또는 `.fixed` (6주)
- `TSCalendarScrollDirection`: `.vertical` 또는 `.horizontal` 스크롤
- `TSCalendarStartWeekDay`: 설정 가능한 주 시작 요일 (일요일-토요일)
- `TSCalendarAppearanceType`: `.app` 또는 `.widget(size)` 스타일링 컨텍스트

## 아키텍처 상세

### 데이터 구조

라이브러리는 효율적인 날짜 관리를 위해 3차원 배열 구조를 사용합니다:
```swift
datesData: [[[TSCalendarDate]]]
// datesData[페이지인덱스][주인덱스][일인덱스]
// 예시: datesData[1][2][3] = 2번째 페이지, 3번째 주, 4번째 날
```

**페이징 시스템**:
- 트리플 버퍼 아키텍처 (이전, 현재, 다음 페이지)
- 부드러운 전환을 위해 항상 3개 페이지를 메모리에 유지
- 네비게이션 시 페이지를 재활용해 메모리 사용 최소화

**뷰 재구성 전략**:
- 설정 변경 시 `.id(config.id)`를 통해 뷰 재구성 트리거
- `heightStyle`은 부드러운 애니메이션을 위해 `id` 계산에서 제외
- 높이 변경은 별도의 `@Published currentHeight` 프로퍼티 사용

### 상태 관리 흐름

**날짜 선택 플로우**:
```
사용자 탭 → TSCalendarWeekView
    ↓
viewModel.selectDate(date)
    ↓
1. 날짜 정규화 (startOfDay)
2. min/max 날짜 검증
3. selectedDate 프로퍼티 업데이트
4. 현재 표시된 월과 비교
5. 다른 월이면 네비게이션
6. datesData 재생성
7. delegate.calendar(didSelect:) 호출
    ↓
TSCalendar.onChange가 변경 감지
    ↓
부모 @Binding 업데이트
```

**설정 변경 플로우**:
- SwiftUI: `.id(config.id)`로 뷰 재생성 강제
- UIKit: `calendarSettingsDidChange` 퍼블리셔가 수동 리로드 트리거
- 높이 변경: `@Published currentHeight`를 통한 애니메이션 (전체 재구성 없음)

### 이벤트 레이아웃 알고리즘

이벤트는 탐욕적 행 패킹(greedy row-packing) 알고리즘으로 정렬됩니다:
1. 시작 날짜로 이벤트 정렬
2. 겹치지 않는 이벤트를 행에 패킹 (좌→우)
3. 오버플로우 이벤트는 다음 행으로
4. 최대 표시 가능 행 계산: `(height - moreHeight) / rowHeight`
5. 숨겨진 이벤트는 컬럼별 "+N" 표시기로 표시

## 알려진 이슈 및 기술 부채

### 크리티컬 버그 (최신 버전에서 수정됨)

#### 1. Calendar+Extension.swift의 Force Unwrap
- **위험**: 날짜 계산 실패 시 잠재적 크래시
- **위치**: 13, 20번 라인
- **영향도**: HIGH - 잘못된 달력이나 극단적 날짜에서 런타임 크래시
- **상태**: 수정 완료 - guard let과 fallback 값 사용

#### 2. 양방향 바인딩 루프
- **위험**: 부모 바인딩과 ViewModel 간 무한 업데이트 사이클
- **위치**: TSCalendar.swift 48-53번 라인
- **영향도**: MEDIUM - 성능 저하, 불필요한 업데이트
- **상태**: 수정 완료 - 중복 업데이트 방지를 위한 값 비교 추가

#### 3. 제스처 핸들러의 레이스 컨디션
- **위험**: 빠른 스와이프 시 여러 비동기 작업이 겹칠 수 있음
- **위치**: TSCalendarPagingView.swift 73-78번 라인
- **영향도**: HIGH - 잘못된 날짜로 이동, 데이터 불일치
- **상태**: 수정 완료 - 취소 가능한 DispatchWorkItem 사용

#### 4. 날짜 범위 검증 누락
- **위험**: `minimumDate > maximumDate`일 때 정의되지 않은 동작
- **위치**: TSCalendar.swift init
- **영향도**: MEDIUM - 잘못된 초기화, 예상치 못한 동작
- **상태**: 수정 완료 - assertion과 자동 조정으로 검증 추가

### 아키텍처 패턴

- **MVVM with Combine**: ViewModel이 상태 관리, Config가 변경 발행
- **Delegate/DataSource 패턴**: Weak 참조로 retain cycle 방지
- **Environment 기반 스타일링**: SwiftUI environment를 통해 Appearance 주입
- **프로토콜 커스터마이징**: TSCalendarCustomization으로 기본 뷰 교체 가능

### 성능 고려사항

- **설정 변경 시 전체 뷰 재생성**: `.id(config.id)`로 인한 비용이 큰 작업
- **뷰 body에서 이벤트 처리**: 매 업데이트마다 재실행 (메모이제이션 필요)
- **GeometryReader 과다 사용**: 주 행당 7개 생성으로 레이아웃 오버헤드
- **날짜 배열 재생성**: 스크롤 중 자주 호출됨 (캐싱 가능)

### 코드 품질 노트

- **코드 중복**: 거의 동일한 4개의 페이징 뷰 구현 (FixedHeight/FlexibleHeight × Horizontal/Vertical)
- **매직 넘버**: `transitionDelay = 0.3`, `dragThreshold = 50` 같은 하드코딩된 값
- **주석**: 한글 주석 사용 (한국 개발자를 위해 유지)

### 테스트 전략

- 현재 자동화된 테스트 없음
- 수동 테스트 중점 항목:
  - 월/주 뷰 전환
  - 월 경계 넘어서 날짜 선택
  - 겹치는 이벤트 표시
  - Min/max 날짜 경계
  - 설정 변경
  - 다양한 크기의 위젯 렌더링

### 타임존 처리

- `.gregorian` identifier와 함께 `Calendar.current` 사용
- 이벤트 날짜 비교는 `Calendar.isDate(_:inSameDayAs:)` 사용
- 일관된 비교를 위해 날짜를 day 시작으로 정규화
- 모든 날짜는 사용자의 현재 타임존 가정

### 접근성

**현재 상태**: 제한적인 접근성 지원
- VoiceOver 레이블 미구현
- Dynamic Type 미지원 (고정 폰트 크기)
- WCAG 기준 색상 대비 미검증

**로드맵**: v2.0에서 접근성 개선 예정

## 코드 네비게이션 가이드

### 진입점
- **TSCalendar.swift**: 메인 SwiftUI 뷰, 초기화, 바인딩 조정
- **TSCalendarUIView.swift**: UIKit 래퍼, hosting controller 관리

### 핵심 로직
- **TSCalendarViewModel.swift**: 상태 관리, 날짜 계산, 네비게이션
- **TSCalendarConfig.swift**: 설정 객체, 반응형 퍼블리셔
- **TSCalendarAppearance.swift**: 스타일링 시스템, 위젯 크기 적응

### 뷰 계층 구조
- **TSCalendarView.swift**: 루트 내부 뷰, 헤더 + 요일 + 콘텐츠
- **TSCalendarPagingView.swift**: 복잡한 페이징 로직 (4가지 구현)
- **TSCalendarWeekView.swift**: 주 행 렌더링, 이벤트 오버레이
- **TSCalendarEventsView.swift**: 이벤트 레이아웃 알고리즘, 겹침 해결

### 유틸리티
- **Calendar+Extension.swift**: 날짜 헬퍼 메서드
- **Collection+Extension.swift**: 안전한 배열 subscripting
- **Text+Extension.swift**: 텍스트 스타일링 유틸리티
- **View+SizeReader.swift**: GeometryReader 기반 크기 모니터링

### Public API
- **TSCalendarProtocols.swift**: Delegate 및 DataSource 프로토콜
- **TSCalendarCustomization.swift**: 커스텀 뷰 주입
- **TSCalendarEnums.swift**: Public 열거형
- **Models/**: TSCalendarDate, TSCalendarEvent, TSCalendarContentStyle
