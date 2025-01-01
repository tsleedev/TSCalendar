//
//  CalendarProtocols.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

public protocol TSCalendarAppearanceProtocol: Sendable {
    var weekdaySymbols: [String] { get }
    var dateFormatter: DateFormatter { get }
    
    // Header Title Format
    func getHeaderTitle(date: Date, displayMode: TSCalendarDisplayMode) -> String
    
    // Colors
    var todayColor: Color { get }
    var selectedColor: Color { get }
    var weekdayHeaderColor: Color { get }
    var saturdayColor: Color { get }
    var sundayColor: Color { get }
    var weekdayColor: Color { get }
    
    // Sizes
    var daySize: CGFloat { get }
    var monthHeaderHeight: CGFloat { get }  // 년월 표시 영역 높이
    var weekdayHeaderHeight: CGFloat { get } // 요일 표시 영역 높이
    
    // Fonts
    var monthHeaderFont: Font { get }
    var weekdayHeaderFont: Font { get }
    var dayFont: Font { get }
    var eventFont: Font { get }
}

public protocol TSCalendarDataSource: AnyObject {
    func calendar(date: Date) -> [TSCalendarEvent]  // CalendarDayView, WeekView가 아닌 날짜 기반으로 변경
    func calendar(startDate: Date, endDate: Date) -> [TSCalendarEvent]
}

extension TSCalendarDataSource {
    func calendar(date: Date) -> [TSCalendarEvent] { [] }
    func calendar(startDate: Date, endDate: Date) -> [TSCalendarEvent] { [] }
}

public protocol TSCalendarDelegate: AnyObject {
    func calendar(pageWillChange date: Date)
    func calendar(pageDidChange date: Date)
    func calendar(didSelect date: Date)
}

public extension TSCalendarDelegate {
    func calendar(pageWillChange date: Date) {}
    func calendar(pageDidChange date: Date) {}
    func calendar(didSelect date: Date) {}
}
