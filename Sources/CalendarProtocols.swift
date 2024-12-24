//
//  CalendarProtocols.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//


import Foundation

protocol CalendarDataSource {
    func calendar(dayView: CalendarDayView, date: Date)
    func calendar(weekView: CalendarWeekView, startDate: Date, endDate: Date)
}

extension CalendarDataSource {
    func calendar(dayView: CalendarDayView, date: Date) {}
    func calendar(weekView: CalendarWeekView, startDate: Date, endDate: Date) {}
}

public protocol CalendarDelegate: AnyObject {
    func calendar(pageWillChange date: Date)
    func calendar(pageDidChange date: Date)
    func calendar(focusDidChange date: Date)
    func calendar(didSelect date: Date)
}

public extension CalendarDelegate {
    func calendar(pageWillChange date: Date) {}
    func calendar(pageDidChange date: Date) {}
    func calendar(focusDidChange date: Date) {}
    func calendar(didSelect date: Date) {}
}
