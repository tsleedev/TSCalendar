//
//  TSCalendarConfig.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/7/25.
//

import Foundation

public struct TSCalendarConfig {
    public var displayMode: TSCalendarDisplayMode
    public var scrollDirection: TSCalendarScrollDirection
    public var startWeekDay: TSCalendarStartWeekDay
    public var showWeekNumber: Bool
    
    public var id: String {
        "\(displayMode)_\(scrollDirection)_\(startWeekDay)_\(showWeekNumber)"
    }
    
    public init(
        displayMode: TSCalendarDisplayMode = .month,
        scrollDirection: TSCalendarScrollDirection = .vertical,
        startWeekDay: TSCalendarStartWeekDay = .sunday,
        showWeekNumber: Bool = false
    ) {
        self.displayMode = displayMode
        self.scrollDirection = scrollDirection
        self.startWeekDay = startWeekDay
        self.showWeekNumber = showWeekNumber
    }
}
