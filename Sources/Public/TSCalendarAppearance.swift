//
//  CalendarAppearanceProtocol.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/26/24.
//

import SwiftUI

public struct TSCalendarAppearance: Sendable {
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
    public let saturdayColor: Color
    public let sundayColor: Color
    public let weekdayColor: Color
    
    // Opacities
    public let otherMonthDateOpacity: Double
    
    // Sizes
    public let monthHeaderHeight: CGFloat
    public let weekdayHeaderHeight: CGFloat
    public let weekNumberWidth: CGFloat
    public let daySize: CGFloat
    public let eventHeight: CGFloat
    
    // Text Styles
    public let monthHeaderTextStyle: TSCalendarTextStyle
    public let weekdayHeaderTextStyle: TSCalendarTextStyle
    public let weekNumberTextStyle: TSCalendarTextStyle
    public let dayTextStyle: TSCalendarTextStyle
    public let eventTextStyle: TSCalendarTextStyle
    
    public init(type: TSCalendarAppearanceType = .app) {
        switch type {
        case .app:
            self.monthHeaderHeight = 40
            self.weekdayHeaderHeight = 30
            self.weekNumberWidth = 20
            self.daySize = 25
            self.eventHeight = 18
            
            self.monthHeaderTextStyle = TSCalendarTextStyle(
                font: .system(size: 17),
                color: .primary,
                kerning: 0,
                tracking: 0
            )
            self.weekdayHeaderTextStyle = TSCalendarTextStyle(
                font: .system(size: 12),
                color: .gray,
                kerning: 0,
                tracking: 0
            )
            self.weekNumberTextStyle = TSCalendarTextStyle(
                font: .system(size: 12),
                color: .gray,
                kerning: 0,
                tracking: 0
            )
            self.dayTextStyle = TSCalendarTextStyle(
                font: .system(size: 14),
                color: .primary,
                kerning: 0,
                tracking: 0
            )
            self.eventTextStyle = TSCalendarTextStyle(
                font: .system(size: 10),
                color: .gray,
                kerning: 0,
                tracking: -1
            )
            
        case .widget(let size):
            switch size {
            case .small:
                self.monthHeaderHeight = 20
                self.weekdayHeaderHeight = 12
                self.weekNumberWidth = 10
                self.daySize = 15
                self.eventHeight = 15
                
                self.monthHeaderTextStyle = TSCalendarTextStyle(
                    font: .system(size: 10),
                    color: .primary,
                    kerning: 0,
                    tracking: 0
                )
                self.weekdayHeaderTextStyle = TSCalendarTextStyle(
                    font: .system(size: 7),
                    color: .gray,
                    kerning: 0,
                    tracking: 0
                )
                self.weekNumberTextStyle = TSCalendarTextStyle(
                    font: .system(size: 7),
                    color: .gray,
                    kerning: 0,
                    tracking: 0
                )
                self.dayTextStyle = TSCalendarTextStyle(
                    font: .system(size: 9),
                    color: .primary,
                    kerning: 0,
                    tracking: 0
                )
                self.eventTextStyle = TSCalendarTextStyle(
                    font: .system(size: 6),
                    color: .gray,
                    kerning: 0,
                    tracking: -1
                )
                
            case .medium:
                self.monthHeaderHeight = 20
                self.weekdayHeaderHeight = 20
                self.weekNumberWidth = 15
                self.daySize = 25
                self.eventHeight = 15
                
                self.monthHeaderTextStyle = TSCalendarTextStyle(
                    font: .system(size: 14),
                    color: .primary,
                    kerning: 0,
                    tracking: 0
                )
                self.weekdayHeaderTextStyle = TSCalendarTextStyle(
                    font: .system(size: 10),
                    color: .gray,
                    kerning: 0,
                    tracking: 0
                )
                self.weekNumberTextStyle = TSCalendarTextStyle(
                    font: .system(size: 10),
                    color: .gray,
                    kerning: 0,
                    tracking: 0
                )
                self.dayTextStyle = TSCalendarTextStyle(
                    font: .system(size: 12),
                    color: .primary,
                    kerning: 0,
                    tracking: 0
                )
                self.eventTextStyle = TSCalendarTextStyle(
                    font: .system(size: 10),
                    color: .gray,
                    kerning: 0,
                    tracking: -1
                )
                
            case .large:
                self.monthHeaderHeight = 25
                self.weekdayHeaderHeight = 10
                self.weekNumberWidth = 20
                self.daySize = 17
                self.eventHeight = 13
                
                self.monthHeaderTextStyle = TSCalendarTextStyle(
                    font: .system(size: 15),
                    color: .primary,
                    kerning: 0,
                    tracking: 0
                )
                self.weekdayHeaderTextStyle = TSCalendarTextStyle(
                    font: .system(size: 9),
                    color: .gray,
                    kerning: 0,
                    tracking: 0
                )
                self.weekNumberTextStyle = TSCalendarTextStyle(
                    font: .system(size: 10),
                    color: .gray,
                    kerning: 0,
                    tracking: 0
                )
                self.dayTextStyle = TSCalendarTextStyle(
                    font: .system(size: 10, weight: .semibold),
                    color: .primary,
                    kerning: 0,
                    tracking: 0
                )
                self.eventTextStyle = TSCalendarTextStyle(
                    font: .system(size: 9, weight: .bold),
                    color: .gray,
                    kerning: 0,
                    tracking: -0.5
                )
            }
        }
        
        self.todayColor = .gray.opacity(0.5)
        self.selectedColor = .gray.opacity(0.5)
        self.saturdayColor = .blue
        self.sundayColor = .red
        self.weekdayColor = .primary
        self.otherMonthDateOpacity = 0.3
    }
    
    // Default Initializer
    public init(
        todayColor: Color = .gray.opacity(0.5),
        selectedColor: Color = .gray.opacity(0.5),
        saturdayColor: Color = .blue,
        sundayColor: Color = .red,
        weekdayColor: Color = .primary,
        otherMonthDateOpacity: CGFloat = 0.3,
        monthHeaderHeight: CGFloat = 20,
        weekdayHeaderHeight: CGFloat = 12,
        weekNumberWidth: CGFloat = 15,
        daySize: CGFloat = 25,
        eventHeight: CGFloat = 18,
        monthHeaderFont: Font = .system(size: 17),
        weekdayHeaderFont: Font = .system(size: 12),
        weekNumberFont: Font = .system(size: 13),
        dayFont: Font = .system(size: 14),
        eventFont: Font = .system(size: 10),
        monthHeaderColor: Color = .primary,
        weekdayHeaderColor: Color = .gray,
        weekNumberColor: Color = .gray,
        dayColor: Color = .primary,
        eventColor: Color = .gray,
        kerning: CGFloat = 0,
        tracking: CGFloat = 0
    ) {
        // 독립적인 색상 초기화
        self.todayColor = todayColor
        self.selectedColor = selectedColor
        self.saturdayColor = saturdayColor
        self.sundayColor = sundayColor
        self.weekdayColor = weekdayColor
        self.otherMonthDateOpacity = otherMonthDateOpacity
        self.monthHeaderHeight = monthHeaderHeight
        self.weekdayHeaderHeight = weekdayHeaderHeight
        self.weekNumberWidth = weekNumberWidth
        self.daySize = daySize
        self.eventHeight = eventHeight
        
        // 텍스트 스타일 초기화
        self.monthHeaderTextStyle = TSCalendarTextStyle(
            font: monthHeaderFont,
            color: monthHeaderColor,
            kerning: kerning,
            tracking: tracking
        )
        self.weekdayHeaderTextStyle = TSCalendarTextStyle(
            font: weekdayHeaderFont,
            color: weekdayHeaderColor,
            kerning: kerning,
            tracking: tracking
        )
        self.weekNumberTextStyle = TSCalendarTextStyle(
            font: weekNumberFont,
            color: weekNumberColor,
            kerning: kerning,
            tracking: tracking
        )
        self.dayTextStyle = TSCalendarTextStyle(
            font: dayFont,
            color: dayColor,
            kerning: kerning,
            tracking: tracking
        )
        self.eventTextStyle = TSCalendarTextStyle(
            font: eventFont,
            color: eventColor,
            kerning: kerning,
            tracking: tracking
        )
    }
}
