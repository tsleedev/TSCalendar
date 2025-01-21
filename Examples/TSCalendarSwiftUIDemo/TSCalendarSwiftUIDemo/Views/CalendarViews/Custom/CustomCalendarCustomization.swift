//
//  CustomCalendarCustomization.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 1/21/25.
//

import SwiftUI
import TSCalendar

struct CustomCalendarCustomization: TSCalendarCustomization {
    var weekView: (([TSCalendarDate], _ didSelectDate: @escaping (Date) -> Void) -> AnyView)? = { weekData, didSelectDate in
        AnyView(
            CustomWeekView(
                weekData: weekData,
                didSelectDate: didSelectDate
            )
        )
    }
}
