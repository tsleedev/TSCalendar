//
//  TSCalendarEnvironment.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/1/25.
//

import Foundation

public struct TSCalendarEnvironment: Sendable {
    public let showNavigationButtons: Bool
    public let isPagingEnabled: Bool
    public let autoSelectToday: Bool
    
    public static let app = TSCalendarEnvironment(
        showNavigationButtons: true,
        isPagingEnabled: true,
        autoSelectToday: true
    )
    
    public static let widget = TSCalendarEnvironment(
        showNavigationButtons: false,
        isPagingEnabled: false,
        autoSelectToday: false
    )
}
