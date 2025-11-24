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

public enum TSCalendarHeightStyle: Equatable {
    case flexible
    case fixed(CGFloat)
    
    public var height: CGFloat? {
        switch self {
        case .flexible:
            return nil
        case .fixed(let height):
            return height
        }
    }
    
    public var isFlexible: Bool {
        return self == .flexible
    }
    
    public var isFixed: Bool {
        if case .fixed = self {
            return true
        }
        return false
    }
}

public enum TSCalendarMonthStyle {
    case fixed    // 항상 6주 표시 (42일)
    case dynamic  // 현재 달에 필요한 주 수만큼만 표시
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

/// 요일 헤더 심볼 타입
public enum TSCalendarWeekdaySymbolType: String, CaseIterable {
    /// 매우 짧은 형식: S, M, T, W, T, F, S (영어) / 일, 월, 화... (한국어 등)
    case veryShort = "Very Short"
    /// 짧은 형식: Sun, Mon, Tue... (영어) / 일, 월, 화... (한국어)
    case short = "Short"
    /// 한 글자 형식: S, M, T... (영어) / 일, 월, 화... (한국어)
    case narrow = "Narrow"

    public var description: String {
        return self.rawValue
    }
}

/// 이벤트 표시 스타일
public enum TSCalendarEventDisplayStyle: String, CaseIterable {
    /// 가로 바 형태 (기본값)
    case bars = "Bars"
    /// 점 표시
    case dots = "Dots"
    /// 숫자 표시 (+1, +2)
    case count = "Count"
    /// 표시 안함
    case none = "None"

    public var description: String {
        return self.rawValue
    }
}
