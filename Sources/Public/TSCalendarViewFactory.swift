//
//  TSCalendarViewFactory.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

@MainActor
public struct TSCalendarViewFactory {
    public static func createCalendarView() -> some View {
        CalendarView(
            minimumDate: Date(),
            maximumDate: Date(),
            environment: .app
        )
    }
}
