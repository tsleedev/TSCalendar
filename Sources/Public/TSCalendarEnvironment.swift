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
    public let monthStyle: TSCalendarMonthStyle
    
    public static let app = TSCalendarEnvironment(
        showNavigationButtons: true,
        isPagingEnabled: true,
        autoSelectToday: true,
        monthStyle: .dynamic
    )
    
    public static let widget = TSCalendarEnvironment(
        showNavigationButtons: false,
        isPagingEnabled: false,
        autoSelectToday: false,
        monthStyle: .dynamic
    )
}

public enum TSCalendarMonthStyle: Sendable {
    case fixed    // 항상 6주 표시 (42일)
    case dynamic  // 현재 달에 필요한 주 수만큼만 표시
}
