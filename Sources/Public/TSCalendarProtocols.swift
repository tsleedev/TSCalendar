//
//  CalendarProtocols.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

public protocol TSCalendarDataSource: AnyObject {
    func calendar(date: Date) -> [TSCalendarEvent]
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
