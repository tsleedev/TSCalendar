//
//  CalendarAppearanceProtocol.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/26/24.
//

import SwiftUI

public struct TSCalendarAppearance: TSCalendarAppearanceProtocol {
    // Formatters
    public let weekdaySymbols = Calendar.current.shortWeekdaySymbols.map { $0.uppercased() }
    public let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    public func getHeaderTitle(date: Date, displayMode: TSCalendarDisplayMode) -> String {
        let dateFormatter = DateFormatter()
        switch displayMode {
        case .month:
            dateFormatter.dateFormat = DateFormatter.dateFormat(
                fromTemplate: "MMMM yyyy",
                options: 0,
                locale: Locale.current
            )
            return dateFormatter.string(from: date)
            
        case .week:
            dateFormatter.dateFormat = DateFormatter.dateFormat(
                fromTemplate: "MMMM yyyy",
                options: 0,
                locale: Locale.current
            )
            let weekText = "Week"
            let weekNumber = Calendar.current.component(.weekOfMonth, from: date)
            return "\(dateFormatter.string(from: date)) \(weekText) \(weekNumber)"
        }
    }
    
    // Colors
    public let todayColor: Color
    public let selectedColor: Color
    public let weekdayHeaderColor: Color
    public let weekNumberColor: Color
    public let saturdayColor: Color
    public let sundayColor: Color
    public let weekdayColor: Color
    
    // Sizes
    public let weekNumberWidth: CGFloat
    public let daySize: CGFloat
    public let monthHeaderHeight: CGFloat
    public let weekdayHeaderHeight: CGFloat
    
    // Fonts
    public let monthHeaderFont: Font
    public let weekdayHeaderFont: Font
    public let weekNumberFont: Font
    public let dayFont: Font
    public let eventFont: Font
    
    public init(type: TSCalendarAppearanceType = .app) {
        switch type {
        case .app:
            self.weekNumberWidth = 20
            self.daySize = 25
            self.monthHeaderHeight = 40
            self.weekdayHeaderHeight = 30
            self.monthHeaderFont = .system(size: 17)
            self.weekdayHeaderFont = .system(size: 12)
            self.weekNumberFont = .system(size: 12)
            self.dayFont = .system(size: 14)
            self.eventFont = .system(size: 10)
            
        case .widget(let size):
            switch size {
            case .small:
                self.weekNumberWidth = 10
                self.daySize = 15
                self.monthHeaderHeight = 20
                self.weekdayHeaderHeight = 12
                self.monthHeaderFont = .system(size: 10)
                self.weekdayHeaderFont = .system(size: 7)
                self.weekNumberFont = .system(size: 7)
                self.dayFont = .system(size: 9)
                self.eventFont = .system(size: 6)
                
            case .medium:
                self.weekNumberWidth = 15
                self.daySize = 25
                self.monthHeaderHeight = 20
                self.weekdayHeaderHeight = 20
                self.monthHeaderFont = .system(size: 14)
                self.weekdayHeaderFont = .system(size: 10)
                self.weekNumberFont = .system(size: 10)
                self.dayFont = .system(size: 12)
                self.eventFont = .system(size: 10)
                
            case .large:
                self.weekNumberWidth = 20
                self.daySize = 25
                self.monthHeaderHeight = 25
                self.weekdayHeaderHeight = 25
                self.monthHeaderFont = .system(size: 16)
                self.weekdayHeaderFont = .system(size: 11)
                self.weekNumberFont = .system(size: 11)
                self.dayFont = .system(size: 13)
                self.eventFont = .system(size: 10)
            }
        }
        
        self.todayColor = .gray.opacity(0.5)
        self.selectedColor = .gray.opacity(0.5)
        self.weekdayHeaderColor = .gray
        self.weekNumberColor = .gray
        self.saturdayColor = .blue
        self.sundayColor = .red
        self.weekdayColor = .primary
    }
    
    init(
        todayColor: Color = .gray.opacity(0.5),
        selectedColor: Color = .gray.opacity(0.5),
        weekdayHeaderColor: Color = .gray,
        weekNumberColor: Color = .gray,
        saturdayColor: Color = .blue,
        sundayColor: Color = .red,
        weekdayColor: Color = .primary,
        weekNumberWidth: CGFloat = 15,
        daySize: CGFloat = 25,
        monthHeaderHeight: CGFloat = 20,
        weekdayHeaderHeight: CGFloat = 12,
        monthHeaderFont: Font = .system(size: 17),
        weekdayHeaderFont: Font = .system(size: 12),
        weekNumberFont: Font = .system(size: 13),
        dayFont: Font = .system(size: 14),
        eventFont: Font = .system(size: 10)
    ) {
        self.todayColor = todayColor
        self.selectedColor = selectedColor
        self.weekdayHeaderColor = weekdayHeaderColor
        self.weekNumberColor = weekNumberColor
        self.saturdayColor = saturdayColor
        self.sundayColor = sundayColor
        self.weekdayColor = weekdayColor
        self.weekNumberWidth = weekNumberWidth
        self.daySize = daySize
        self.monthHeaderHeight = monthHeaderHeight
        self.weekdayHeaderHeight = weekdayHeaderHeight
        self.monthHeaderFont = monthHeaderFont
        self.weekdayHeaderFont = weekdayHeaderFont
        self.weekNumberFont = weekNumberFont
        self.dayFont = dayFont
        self.eventFont = eventFont
    }
}
