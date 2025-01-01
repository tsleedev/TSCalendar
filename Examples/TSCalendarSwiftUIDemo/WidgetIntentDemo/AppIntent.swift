//
//  AppIntent.swift
//  WidgetIntentDemo
//
//  Created by TAE SU LEE on 12/27/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Select Time Range" }
    static var description: IntentDescription { "Choose a time range to display the calendar in months or weeks." }

    @Parameter(title: "Time Range", default: .current)
    var selectedOffset: TimeRange

    enum TimeRange: Int, AppEnum {
        case minus2 = -2
        case minus1 = -1
        case current = 0
        case plus1 = 1
        case plus2 = 2

        static var typeDisplayRepresentation: TypeDisplayRepresentation {
            "Time Range"
        }

        static var caseDisplayRepresentations: [TimeRange: DisplayRepresentation] {
            [
                .minus2: "-2 Months / -2 Weeks",
                .minus1: "-1 Months / -1 Week",
                .current: "This Month / This Week",
                .plus1: "+1 Month / 1 Week",
                .plus2: "+2 Months / 2 Weeks"
            ]
        }
    }
}
