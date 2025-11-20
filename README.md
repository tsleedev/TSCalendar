# TSCalendar

iOS 15+ 용 SwiftUI & UIKit 달력 라이브러리

[![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://www.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

## ✨ 주요 기능

- **SwiftUI & UIKit 지원**: 두 프레임워크 모두에서 사용 가능
- **유연한 뷰 모드**: 월(Month) / 주(Week) 뷰 전환
- **다양한 스타일**: 동적/고정 월 스타일, 수직/수평 스크롤
- **커스터마이징**: 외형, 색상, 폰트, 이벤트 표시 등 모든 것을 설정 가능
- **이벤트 표시**: 다중 날짜 이벤트, 겹침 처리, 오버플로우 표시
- **위젯 지원**: Small/Medium/Large 위젯 크기별 최적화
- **반응형 설정**: Combine 기반 실시간 설정 업데이트
- **Delegate & DataSource**: 프로토콜 기반 이벤트 처리

## 📋 요구사항

- iOS 15.0+
- Swift 6.0+
- Xcode 15.0+

## 📦 설치

### Swift Package Manager

#### Xcode에서 설치
1. Xcode에서 프로젝트 선택
2. `File` → `Add Package Dependencies...`
3. 다음 URL 입력:
   ```
   https://github.com/tsleedev/TSCalendar.git
   ```
4. 버전 선택: `0.4.0` 이상

#### Package.swift에 추가
```swift
dependencies: [
    .package(url: "https://github.com/tsleedev/TSCalendar.git", from: "0.4.0")
]
```

## 🚀 기본 사용법

### SwiftUI

```swift
import SwiftUI
import TSCalendar

struct ContentView: View {
    @State private var selectedDate: Date? = Date()
    @StateObject private var config = TSCalendarConfig()
    
    var body: some View {
        TSCalendar(
            selectedDate: $selectedDate,
            config: config
        )
    }
}
```

### UIKit

```swift
import UIKit
import TSCalendar

class ViewController: UIViewController {
    private var calendarView: TSCalendarUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView = TSCalendarUIView(
            config: TSCalendarConfig()
        )
        
        view.addSubview(calendarView)
        // Auto Layout 설정...
    }
}
```

## 🎯 프로그래매틱 제어

### 달력 네비게이션

외부에서 달력을 프로그래매틱하게 이동시킬 수 있습니다. 커스텀 헤더를 만들 때 유용합니다.

#### SwiftUI - currentDisplayedDate Binding (권장)

```swift
import SwiftUI
import TSCalendar

struct ContentView: View {
    @State private var currentDisplayedDate = Date()
    @State private var selectedDate: Date? = Date()
    @StateObject private var config = TSCalendarConfig(showHeader: false)

    var body: some View {
        VStack {
            // 커스텀 헤더
            HStack {
                Button("◀︎") {
                    currentDisplayedDate = Calendar.current.date(
                        byAdding: .month,
                        value: -1,
                        to: currentDisplayedDate
                    ) ?? currentDisplayedDate
                }

                Text(monthYearString(from: currentDisplayedDate))
                    .font(.headline)

                Button("▶︎") {
                    currentDisplayedDate = Calendar.current.date(
                        byAdding: .month,
                        value: 1,
                        to: currentDisplayedDate
                    ) ?? currentDisplayedDate
                }
            }
            .padding()

            // currentDisplayedDate binding으로 제어
            TSCalendar(
                currentDisplayedDate: $currentDisplayedDate,
                selectedDate: $selectedDate,
                config: config
            )
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }
}
```

#### UIKit

```swift
import UIKit
import TSCalendar

class ViewController: UIViewController {
    private var calendarView: TSCalendarUIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView = TSCalendarUIView(
            config: TSCalendarConfig()
        )

        view.addSubview(calendarView)
        // Auto Layout 설정...
    }

    @objc func previousButtonTapped() {
        calendarView.moveToPrevious()  // 이전 월/주로 이동
    }

    @objc func nextButtonTapped() {
        calendarView.moveToNext()  // 다음 월/주로 이동
    }

    @objc func jumpToDate() {
        // 특정 날짜로 여러 단계 이동
        calendarView.move(by: 3)   // 3개월 앞으로
        calendarView.move(by: -2)  // 2개월 뒤로
    }
}
```

### SwiftUI 제어 방법

**1. currentDisplayedDate Binding (권장)**
```swift
@State private var currentDisplayedDate = Date()

TSCalendar(
    currentDisplayedDate: $currentDisplayedDate,  // 양방향 바인딩
    selectedDate: $selectedDate,
    config: config
)

// 날짜 변경으로 달력 이동
currentDisplayedDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDisplayedDate)!
```

**2. UIKit 메서드 (UIKit 전용)**
```swift
// TSCalendarUIView에서 사용 가능
calendarView.moveToNext()
calendarView.moveToPrevious()
calendarView.move(by: 3)
```

**참고**: 네비게이션 시 `calendar(pageDidChange:)` delegate만 호출되며, `calendar(didSelect:)`는 호출되지 않습니다. 이는 페이지 이동과 날짜 선택을 명확히 구분하기 위함입니다.

## ⚙️ 설정

### TSCalendarConfig

```swift
let config = TSCalendarConfig()

// 표시 모드
config.displayMode = .month  // .month 또는 .week

// 월 스타일
config.monthStyle = .dynamic  // .dynamic (가변 주) 또는 .fixed (6주 고정)

// 높이 스타일
config.heightStyle = .flexible  // .flexible 또는 .fixed(CGFloat)

// 스크롤 방향
config.scrollDirection = .vertical  // .vertical 또는 .horizontal

// 주 시작 요일
config.startWeekDay = .sunday  // .sunday ~ .saturday

// 페이징 활성화
config.isPagingEnabled = true

// 헤더 표시
config.showHeader = true

// 주차 번호 표시
config.showWeekNumber = false

// 오늘 날짜 자동 선택
config.autoSelectToday = true
```

### TSCalendarAppearance

```swift
var appearance = TSCalendarAppearance(type: .app)

// 색상 설정
appearance.todayColor = .blue
appearance.selectedColor = .orange
appearance.saturdayColor = .blue
appearance.sundayColor = .red

// 텍스트 스타일 설정
appearance.dayContentStyle = TSCalendarContentStyle(
    font: .system(size: 16),
    color: .primary
)

TSCalendar(
    config: config,
    appearance: appearance
)
```

### 이벤트 표시

```swift
class MyDataSource: TSCalendarDataSource {
    func calendar(startDate: Date, endDate: Date) -> [TSCalendarEvent] {
        return [
            TSCalendarEvent(
                title: "회의",
                startDate: startDate,
                endDate: startDate,
                backgroundColor: .blue.opacity(0.15),
                textColor: .blue
            )
        ]
    }
}

let dataSource = MyDataSource()

TSCalendar(
    config: config,
    dataSource: dataSource
)
```

### Delegate 사용

```swift
class MyDelegate: TSCalendarDelegate {
    func calendar(didSelect date: Date) {
        print("선택된 날짜: \(date)")
    }
    
    func calendar(pageDidChange date: Date) {
        print("페이지 변경: \(date)")
    }
    
    func calendar(pageWillChange date: Date) {
        print("페이지 변경 예정: \(date)")
    }
}

let delegate = MyDelegate()

TSCalendar(
    config: config,
    delegate: delegate
)
```

## 🎨 커스터마이징

### 커스텀 뷰

```swift
struct MyCustomization: TSCalendarCustomization {
    var weekView: (([TSCalendarDate], @escaping (Date) -> Void) -> AnyView)? {
        return { dates, onSelect in
            AnyView(
                // 커스텀 주 뷰 구현
                MyCustomWeekView(dates: dates, onSelect: onSelect)
            )
        }
    }
}

TSCalendar(
    config: config,
    customization: MyCustomization()
)
```

## 📱 예제 프로젝트

프로젝트에는 다양한 사용 예제가 포함되어 있습니다:

### SwiftUI 예제
- **FullSizeCalendarView**: 전체 화면 달력
- **FixedWeekHeightCalendarView**: 고정 높이 주 뷰
- **CustomHeaderCalendarView**: 커스텀 헤더
- **CustomCalendarView**: 완전 커스터마이징 예제
- **Widget Demo**: 위젯 예제

### UIKit 예제
- UIViewController 기반 통합 예제
- 설정 화면 연동

예제 실행:
```bash
cd Examples/TSCalendarSwiftUIDemo
open TSCalendarSwiftUIDemo.xcodeproj
```

## 📖 상세 문서

더 자세한 정보는 [CLAUDE.md](CLAUDE.md)를 참고하세요.

## 🏗️ 아키텍처

- **MVVM 패턴**: SwiftUI/Combine 기반 반응형 아키텍처
- **프로토콜 기반**: Delegate & DataSource 패턴으로 확장 가능
- **트리플 버퍼 페이징**: 부드러운 스크롤 전환
- **환경 기반 스타일링**: SwiftUI Environment로 테마 주입

## 🐛 알려진 이슈

현재 알려진 주요 버그는 없습니다. 문제를 발견하시면 [Issues](https://github.com/tsleedev/TSCalendar/issues)에 등록해주세요.

## 📝 변경 이력

### 0.4.0 (2025-11-21)
- 선언적 네비게이션 API 추가
  - SwiftUI: `currentDisplayedDate: Binding<Date>?` 파라미터로 양방향 바인딩 지원
  - UIKit: `currentDisplayedDate` 프로퍼티로 현재 표시 날짜 접근/설정
  - ViewModel에 `moveTo(date:)` 메서드 추가
- 네비게이션과 선택의 명확한 분리
  - 네비게이션: `pageDidChange` delegate만 호출
  - 선택: `didSelect` delegate 호출
- CustomHeaderCalendarView 예제 개선 (SwiftUI, UIKit)
- StateObject 라이프사이클 이슈 해결

### 0.3.2 (2025-11-21)
- 프로그래매틱 네비게이션 API 추가
  - `moveToNext()`: 다음 월/주로 이동
  - `moveToPrevious()`: 이전 월/주로 이동
  - `move(by:)`: N개 월/주 이동
- 커스텀 헤더 구현을 위한 외부 제어 기능 강화
- SwiftUI 및 UIKit 모두 지원

### 0.3.0 (2025-11-18)
- UIKit 지원 추가 (TSCalendarUIView)
- 크리티컬 버그 수정 (force unwrap, 레이스 컨디션, 바인딩 루프)
- 설정 화면 반응형 업데이트 개선
- Combine 기반 설정 관리 시스템
- 커스터마이징 프로토콜 추가
- Widget 지원 강화
- 문서화 완성

### 0.2.1 (2025-01-10)
- TabView를 DragGesture로 변경

### 0.2.0 (2025-01-04)
- weekNumber 기능 추가

### 0.1.1 (2025-01-01)
- out of range 처리 추가

### 0.1.0 (2025-01-01)
- 첫 릴리스

## 👨‍💻 작성자

**TAE SU LEE**
- Email: tslee.dev@gmail.com
- GitHub: [@tsleedev](https://github.com/tsleedev)

## 📄 라이선스

TSCalendar는 MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

## 🙏 기여

버그 리포트, 기능 제안, Pull Request를 환영합니다!

1. 이 저장소를 Fork 하세요
2. Feature 브랜치를 생성하세요 (`git checkout -b feature/AmazingFeature`)
3. 변경사항을 커밋하세요 (`git commit -m 'Add some AmazingFeature'`)
4. 브랜치에 푸시하세요 (`git push origin feature/AmazingFeature`)
5. Pull Request를 생성하세요
