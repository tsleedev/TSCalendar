//
//  AppIntent.swift
//  WidgetIntentDemo
//
//  Created by TAE SU LEE on 12/27/24.
//

import WidgetKit
import AppIntents

// MARK: - Widget Configuration Intent
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

// MARK: - Navigation Storage
enum WidgetNavigationStorage {
    private static let key = "widget_calendar_offset"

    static var currentOffset: Int {
        get { UserDefaults.standard.integer(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

// MARK: - Navigation Intents
struct NavigatePreviousIntent: AppIntent {
    static var title: LocalizedStringResource { "Previous Month" }
    static var description: IntentDescription { "Navigate to previous month" }

    func perform() async throws -> some IntentResult {
        WidgetNavigationStorage.currentOffset -= 1
        WidgetCenter.shared.reloadTimelines(ofKind: "WidgetIntentDemo")
        return .result()
    }
}

struct NavigateNextIntent: AppIntent {
    static var title: LocalizedStringResource { "Next Month" }
    static var description: IntentDescription { "Navigate to next month" }

    func perform() async throws -> some IntentResult {
        WidgetNavigationStorage.currentOffset += 1
        WidgetCenter.shared.reloadTimelines(ofKind: "WidgetIntentDemo")
        return .result()
    }
}

struct NavigateTodayIntent: AppIntent {
    static var title: LocalizedStringResource { "Today" }
    static var description: IntentDescription { "Navigate to current month" }

    func perform() async throws -> some IntentResult {
        WidgetNavigationStorage.currentOffset = 0
        WidgetCenter.shared.reloadTimelines(ofKind: "WidgetIntentDemo")
        return .result()
    }
}
