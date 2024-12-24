//
//  CalendarDate.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import Foundation

// MARK: - Models
struct CalendarDate: Identifiable {
    let id = UUID()
    let date: Date
    var isSelected: Bool = false
    var isToday: Bool = false
    var isInCurrentMonth: Bool = true
}

// MARK: - Enums
enum CalendarStyle {
    case circle
    case rectangle
}

enum CalendarDayOfTheWeek {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

// MARK: - Calendar Extensions
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
    
    func endOfMonth(for date: Date) -> Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return self.date(byAdding: components, to: startOfMonth(for: date))!
    }
}
