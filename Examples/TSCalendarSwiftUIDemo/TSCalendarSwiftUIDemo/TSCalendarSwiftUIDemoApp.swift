//
//  TSCalendarSwiftUIDemoApp.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI
import TSCalendar

@main
struct TSCalendarSwiftUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            TSCalendarViewFactory.createCalendarView()
        }
    }
}
