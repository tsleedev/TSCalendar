//
//  TSCalendarCustomization.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/17/25.
//

import SwiftUI

public protocol TSCalendarCustomization {
    var weekView: (([TSCalendarDate], _ didSelectDate: @escaping (Date) -> Void) -> AnyView)? { get }
    var eventView: (([TSCalendarDate], TSCalendarEvent, CGFloat) -> AnyView)? { get }
}

public extension TSCalendarCustomization {
    var weekView: (([TSCalendarDate], _ didSelectDate: (Date) -> Void) -> AnyView)? { nil }
    var eventView: (([TSCalendarDate], TSCalendarEvent, CGFloat) -> AnyView)? { nil }
}
