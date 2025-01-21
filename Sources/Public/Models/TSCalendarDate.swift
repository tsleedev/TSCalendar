//
//  TSCalendarDate.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import Foundation

// MARK: - Models
public struct TSCalendarDate: Identifiable {
    public let id = UUID()
    public let date: Date
    public var isSelected: Bool = false
    public var isToday: Bool = false
    public var isInCurrentMonth: Bool = true
    
    public init(date: Date, isSelected: Bool, isToday: Bool, isInCurrentMonth: Bool) {
        self.date = date
        self.isSelected = isSelected
        self.isToday = isToday
        self.isInCurrentMonth = isInCurrentMonth
    }
}
