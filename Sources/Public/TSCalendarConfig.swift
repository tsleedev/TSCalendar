//
//  TSCalendarConfig.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/7/25.
//

import Foundation
import Combine
import AppIntents

public final class TSCalendarConfig: ObservableObject {
    @Published public var autoSelect: Bool
    @Published public var displayMode: TSCalendarDisplayMode
    @Published public var eventDisplayStyle: TSCalendarEventDisplayStyle
    @Published public var heightStyle: TSCalendarHeightStyle
    @Published public var isPagingEnabled: Bool
    @Published public var monthStyle: TSCalendarMonthStyle
    @Published public var scrollDirection: TSCalendarScrollDirection
    @Published public var showHeader: Bool
    @Published public var showWeekNumber: Bool
    @Published public var startWeekDay: TSCalendarStartWeekDay
    @Published public var weekdaySymbolType: TSCalendarWeekdaySymbolType

    /// 위젯용: 날짜 탭 시 앱을 열기 위한 URL 생성 클로저
    /// 설정되면 Link를 사용하여 앱을 엽니다.
    public var widgetDateURL: ((Date) -> URL)?

    /// 위젯용: 날짜 탭 시 실행할 AppIntent 생성 클로저
    /// 설정되면 Button(intent:)를 사용하여 위젯 내에서 동작합니다.
    /// widgetDateIntent가 widgetDateURL보다 우선합니다.
    public var widgetDateIntent: ((Date) -> any AppIntent)?

    /// 위젯용: 이벤트 바 탭 시 실행할 AppIntent 생성 클로저
    /// 설정되면 이벤트 바를 Button(intent:)로 래핑합니다.
    public var widgetEventIntent: ((TSCalendarEvent) -> any AppIntent)?

    // Layout에 영향을 주는 프로퍼티 변경을 모니터링하는 publisher
    // 이 프로퍼티들이 변경되면 ViewModel 재생성이 필요함
    public var layoutDidChange: AnyPublisher<Void, Never> {
        let publishers: [AnyPublisher<Void, Never>] = [
            $displayMode.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $scrollDirection.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $heightStyle.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $monthStyle.dropFirst().map { _ in () }.eraseToAnyPublisher()
        ]

        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }

    // 일반 설정 변경을 모니터링하는 publisher (하위 호환성 유지)
    // 이 프로퍼티들은 @Published 메커니즘으로 자동 반영되므로 reload 불필요
    public var calendarSettingsDidChange: AnyPublisher<Void, Never> {
        let publishers: [AnyPublisher<Void, Never>] = [
            $autoSelect.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $displayMode.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $eventDisplayStyle.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $isPagingEnabled.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $monthStyle.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $scrollDirection.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $showHeader.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $showWeekNumber.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $startWeekDay.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $weekdaySymbolType.dropFirst().map { _ in () }.eraseToAnyPublisher()
        ]

        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }

    private var identifiableProperties: [Any] {
        [
            autoSelect,
            displayMode,
            eventDisplayStyle,
//            heightStyle,      // 외부에서 새로고침 필요
            isPagingEnabled,
            monthStyle,
            scrollDirection,
            showHeader,
            showWeekNumber,
            startWeekDay,
            weekdaySymbolType
        ]
    }

    public var id: String {
        identifiableProperties.map { "\($0)" }.joined(separator: "_")
    }

    public init(
        autoSelect: Bool = true,
        displayMode: TSCalendarDisplayMode = .month,
        eventDisplayStyle: TSCalendarEventDisplayStyle = .bars,
        heightStyle: TSCalendarHeightStyle = .flexible,
        isPagingEnabled: Bool = true,
        monthStyle: TSCalendarMonthStyle = .dynamic,
        scrollDirection: TSCalendarScrollDirection = .vertical,
        showHeader: Bool = true,
        showWeekNumber: Bool = false,
        startWeekDay: TSCalendarStartWeekDay = .sunday,
        weekdaySymbolType: TSCalendarWeekdaySymbolType = .veryShort,
        widgetDateURL: ((Date) -> URL)? = nil,
        widgetDateIntent: ((Date) -> any AppIntent)? = nil,
        widgetEventIntent: ((TSCalendarEvent) -> any AppIntent)? = nil
    ) {
        self.autoSelect = autoSelect
        self.displayMode = displayMode
        self.eventDisplayStyle = eventDisplayStyle
        self.heightStyle = heightStyle
        self.isPagingEnabled = isPagingEnabled
        self.monthStyle = monthStyle
        self.scrollDirection = scrollDirection
        self.showHeader = showHeader
        self.showWeekNumber = showWeekNumber
        self.startWeekDay = startWeekDay
        self.weekdaySymbolType = weekdaySymbolType
        self.widgetDateURL = widgetDateURL
        self.widgetDateIntent = widgetDateIntent
        self.widgetEventIntent = widgetEventIntent
    }
}
