//
//  TSCalendarEnums.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/27/24.
//

import Foundation

public enum TSCalendarAppearanceType {
    case app
    case widget(WidgetSize)
    
    public enum WidgetSize {
        case small   // 전체 달력 작게
        case medium  // 주 달력 + 이벤트
        case large   // 전체 달력 + 이벤트
    }
}

public enum TSCalendarDisplayMode: String, CaseIterable {
    case month = "Month"
    case week = "Week"
    
    public var description: String {
        return self.rawValue
    }
}

public enum TSCalendarScrollDirection: String, CaseIterable {
    case vertical = "Vertical"
    case horizontal = "Horizontal"
    
    public var description: String {
        return self.rawValue
    }
}

public enum TSCalendarStartWeekDay: Int, CaseIterable {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    
    public var description: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}
