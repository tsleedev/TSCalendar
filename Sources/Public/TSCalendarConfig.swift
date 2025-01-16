//
//  TSCalendarConfig.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/7/25.
//

import Foundation

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
