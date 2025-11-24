//
//  TSCalendarConfig.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/7/25.
//

import Foundation
import Combine

public final class TSCalendarConfig: ObservableObject {
    @Published public var autoSelectToday: Bool
    @Published public var displayMode: TSCalendarDisplayMode
    @Published public var heightStyle: TSCalendarHeightStyle
    @Published public var isPagingEnabled: Bool
    @Published public var monthStyle: TSCalendarMonthStyle
    @Published public var scrollDirection: TSCalendarScrollDirection
    @Published public var showHeader: Bool
    @Published public var showWeekNumber: Bool
    @Published public var startWeekDay: TSCalendarStartWeekDay
    @Published public var weekdaySymbolType: TSCalendarWeekdaySymbolType

    // heightStyle 제외한 모든 프로퍼티 변경을 모니터링하는 publisher
    public var calendarSettingsDidChange: AnyPublisher<Void, Never> {
        let publishers: [AnyPublisher<Void, Never>] = [
            $autoSelectToday.dropFirst().map { _ in () }.eraseToAnyPublisher(),
            $displayMode.dropFirst().map { _ in () }.eraseToAnyPublisher(),
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
            autoSelectToday,
            displayMode,
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
        autoSelectToday: Bool = true,
        displayMode: TSCalendarDisplayMode = .month,
        heightStyle: TSCalendarHeightStyle = .flexible,
        isPagingEnabled: Bool = true,
        monthStyle: TSCalendarMonthStyle = .dynamic,
        scrollDirection: TSCalendarScrollDirection = .vertical,
        showHeader: Bool = true,
        showWeekNumber: Bool = false,
        startWeekDay: TSCalendarStartWeekDay = .sunday,
        weekdaySymbolType: TSCalendarWeekdaySymbolType = .veryShort
    ) {
        self.autoSelectToday = autoSelectToday
        self.displayMode = displayMode
        self.heightStyle = heightStyle
        self.isPagingEnabled = isPagingEnabled
        self.monthStyle = monthStyle
        self.scrollDirection = scrollDirection
        self.showHeader = showHeader
        self.showWeekNumber = showWeekNumber
        self.startWeekDay = startWeekDay
        self.weekdaySymbolType = weekdaySymbolType
    }
}
