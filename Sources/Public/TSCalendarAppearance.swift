//
//  CalendarAppearanceProtocol.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/26/24.
//

import SwiftUI

public struct TSCalendarConstants {
    public static let monthHeaderRowHeight: CGFloat = 40
    public static let weekdayHeaderRowHeight: CGFloat = 30
    public static let daySize: CGFloat = 25
    public static let weekNumberWidth: CGFloat = 20
    public static let eventRowHeight: CGFloat = 15
    public static let eventMoreRowHeight: CGFloat = 18
    public static let eventSpacing: CGFloat = 2
}

public struct TSCalendarAppearance: Sendable {
    // Formatters
    public let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    /// 요일 심볼 반환 (타입에 따라)
    public func getWeekdaySymbols(type: TSCalendarWeekdaySymbolType) -> [String] {
        let calendar = Calendar.current
        switch type {
        case .veryShort:
            return calendar.veryShortWeekdaySymbols.map { $0.uppercased() }
        case .short:
            return calendar.shortWeekdaySymbols
        case .narrow:
            // standaloneWeekdaySymbols의 첫 글자 (한국어: 일, 월, 화...)
            return calendar.veryShortStandaloneWeekdaySymbols
        }
    }

    /// 기존 호환성을 위한 기본 weekdaySymbols (deprecated, getWeekdaySymbols 사용 권장)
    public var weekdaySymbols: [String] {
        getWeekdaySymbols(type: .veryShort)
    }
    
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
    
    // Text Styles
    public let monthHeaderContentStyle: TSCalendarContentStyle
    public let weekdayHeaderContentStyle: TSCalendarContentStyle
    public let weekNumberContentStyle: TSCalendarContentStyle
    public let dayContentStyle: TSCalendarContentStyle
    public let eventContentStyle: TSCalendarContentStyle
    public let eventMoreContentStyle: TSCalendarContentStyle
    
    // Default Initializer
    public init(
        todayColor: Color = .gray.opacity(0.5),
        selectedColor: Color = .gray.opacity(0.5),
        saturdayColor: Color = .blue,
        sundayColor: Color = .red,
        weekdayColor: Color = .primary,
        otherMonthDateOpacity: CGFloat = 0.3,
        monthHeaderContentStyle: TSCalendarContentStyle = TSCalendarContentStyle(
            font: .system(size: 17),
            color: .primary,
            rowHeight: TSCalendarConstants.monthHeaderRowHeight
        ),
        weekdayHeaderContentStyle: TSCalendarContentStyle = TSCalendarContentStyle(
            font: .system(size: 12),
            color: .gray,
            rowHeight: TSCalendarConstants.weekdayHeaderRowHeight
        ),
        weekNumberContentStyle: TSCalendarContentStyle = TSCalendarContentStyle(
            font: .system(size: 12),
            color: .gray,
            width: TSCalendarConstants.weekNumberWidth
        ),
        dayContentStyle: TSCalendarContentStyle = TSCalendarContentStyle(
            font: .system(size: 14),
            color: .primary,
            width: TSCalendarConstants.daySize,
            rowHeight: TSCalendarConstants.daySize
        ),
        eventContentStyle: TSCalendarContentStyle = TSCalendarContentStyle(
            font: .system(size: 10),
            color: .gray,
            rowHeight: TSCalendarConstants.eventRowHeight,
            spacing: TSCalendarConstants.eventSpacing
        ),
        eventMoreContentStyle: TSCalendarContentStyle = TSCalendarContentStyle(
            font: .system(size: 10),
            color: .gray,
            rowHeight: TSCalendarConstants.eventMoreRowHeight
        )
    ) {
        // 기본 색상 초기화
        self.todayColor = todayColor
        self.selectedColor = selectedColor
        self.saturdayColor = saturdayColor
        self.sundayColor = sundayColor
        self.weekdayColor = weekdayColor
        self.otherMonthDateOpacity = otherMonthDateOpacity
        
        // 텍스트 스타일 초기화
        self.monthHeaderContentStyle = monthHeaderContentStyle
        self.weekdayHeaderContentStyle = weekdayHeaderContentStyle
        self.weekNumberContentStyle = weekNumberContentStyle
        self.dayContentStyle = dayContentStyle
        self.eventContentStyle = eventContentStyle
        self.eventMoreContentStyle = eventMoreContentStyle
    }
    
    // MARK: - 타입 기반 초기화 메서드
    public init(type: TSCalendarAppearanceType) {
        switch type {
        case .app:
            self.init()
            
        case .widget(let size):
            switch size {
            case .small:
                self.init(
                    todayColor: .gray.opacity(0.5),
                    selectedColor: .gray.opacity(0.5),
                    saturdayColor: .blue,
                    sundayColor: .red,
                    weekdayColor: .primary,
                    otherMonthDateOpacity: 0.3,
                    monthHeaderContentStyle: TSCalendarContentStyle(font: .system(size: 10), color: .primary, rowHeight: 15),
                    weekdayHeaderContentStyle: TSCalendarContentStyle(font: .system(size: 7), color: .gray, rowHeight: 10),
                    weekNumberContentStyle: TSCalendarContentStyle(font: .system(size: 7), color: .gray, width: 10),
                    dayContentStyle: TSCalendarContentStyle(font: .system(size: 9), color: .primary, width: 13, rowHeight: 13),
                    eventContentStyle: TSCalendarContentStyle(font: .system(size: 6), color: .gray, rowHeight: 6, spacing: 1),
                    eventMoreContentStyle: TSCalendarContentStyle(font: .system(size: 6), color: .gray, rowHeight: 5)
                )
            case .medium:
                self.init(
                    todayColor: .gray.opacity(0.5),
                    selectedColor: .gray.opacity(0.5),
                    saturdayColor: .blue,
                    sundayColor: .red,
                    weekdayColor: .primary,
                    otherMonthDateOpacity: 0.3,
                    monthHeaderContentStyle: TSCalendarContentStyle(font: .system(size: 12, weight: .semibold), color: .primary, rowHeight: 20),
                    weekdayHeaderContentStyle: TSCalendarContentStyle(font: .system(size: 9), color: .gray, rowHeight: 10),
                    weekNumberContentStyle: TSCalendarContentStyle(font: .system(size: 10), color: .gray, width: 15),
                    dayContentStyle: TSCalendarContentStyle(font: .system(size: 11, weight: .semibold), color: .primary, width: 18, rowHeight: 18),
                    eventContentStyle: TSCalendarContentStyle(font: .system(size: 10, weight: .semibold), color: .gray, tracking: -0.5, rowHeight: 13, spacing: 1),
                    eventMoreContentStyle: TSCalendarContentStyle(font: .system(size: 7), color: .gray, rowHeight: 9)
                )
            case .large:
                self.init(
                    todayColor: .gray.opacity(0.5),
                    selectedColor: .gray.opacity(0.5),
                    saturdayColor: .blue,
                    sundayColor: .red,
                    weekdayColor: .primary,
                    otherMonthDateOpacity: 0.3,
                    monthHeaderContentStyle: TSCalendarContentStyle(font: .system(size: 12, weight: .semibold), color: .primary, rowHeight: 20),
                    weekdayHeaderContentStyle: TSCalendarContentStyle(font: .system(size: 9), color: .gray, rowHeight: 10),
                    weekNumberContentStyle: TSCalendarContentStyle(font: .system(size: 10), color: .gray, width: 20),
                    dayContentStyle: TSCalendarContentStyle(font: .system(size: 11, weight: .semibold), color: .primary, width: 18, rowHeight: 18),
                    eventContentStyle: TSCalendarContentStyle(font: .system(size: 10, weight: .semibold), color: .gray, tracking: -0.5, rowHeight: 13, spacing: 1),
                    eventMoreContentStyle: TSCalendarContentStyle(font: .system(size: 7), color: .gray, rowHeight: 9)
                )
            }
        }
    }
}
