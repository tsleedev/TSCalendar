//
//  EnvironmentValues+Ext.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/26/24.
//

import SwiftUI

private struct TSCalendarAppearanceKey: EnvironmentKey {
    static let defaultValue: TSCalendarAppearance = TSCalendarAppearance(type: .app)
}

public extension EnvironmentValues {
    var calendarAppearance: TSCalendarAppearance {
        get { self[TSCalendarAppearanceKey.self] }
        set { self[TSCalendarAppearanceKey.self] = newValue }
    }
}
