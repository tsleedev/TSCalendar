//
//  TSCalendarConfig.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/7/25.
//

import Foundation

public struct TSCalendarConfig: Sendable {
    public var autoSelectToday: Bool
    public var displayMode: TSCalendarDisplayMode
    public var heightStyle: TSCalendarHeightStyle
    public var isPagingEnabled: Bool
    public var monthStyle: TSCalendarMonthStyle
    public var scrollDirection: TSCalendarScrollDirection
    public var showHeader: Bool
    public var showWeekNumber: Bool
    public var startWeekDay: TSCalendarStartWeekDay
    
    private var identifiableProperties: [Any] {
        [
            autoSelectToday,
            displayMode,
            heightStyle,
            isPagingEnabled,
            monthStyle,
            scrollDirection,
            showHeader,
            showWeekNumber,
            startWeekDay
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
        startWeekDay: TSCalendarStartWeekDay = .sunday
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
    }
}
