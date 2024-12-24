//
//  CalendarAppearance.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct CalendarAppearance {
    static let shared = CalendarAppearance()
    
    // Formatters
    let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    // Colors
    let todayColor = Color.blue
    let selectedColor = Color.blue.opacity(0.3)
    let weekdayHeaderColor = Color.gray
    let inactiveMonthColor = Color.gray.opacity(0.3)
    let saturdayColor = Color.blue
    let sundayColor = Color.red
    let weekdayColor = Color.primary
    
    // Sizes
    let daySize: CGFloat = 35
    let headerHeight: CGFloat = 30
    
    // Font Sizes
    let headerFontSize: CGFloat = 17
    let weekdayHeaderFontSize: CGFloat = 12
    let dayFontSize: CGFloat = 14
}
