//
//  WidgetLargeView.swift
//  WidgetDemoExtension
//
//  Created by TAE SU LEE on 12/27/24.
//

import SwiftUI
import TSCalendar

struct WidgetLargeView: View {
    @StateObject private var controller = CalendarController()

    var body: some View {
        TSCalendar(
            config: .init(
                displayMode: .month,
                eventDisplayStyle: .bars,
                isPagingEnabled: false,
                monthStyle: .fixed,
                showHeader: false,
                widgetDateURL: Self.buildDateURL
            ),
            appearance: TSCalendarAppearance(type: .widget(.large)),
            delegate: controller,
            dataSource: controller
        )
        .padding(.vertical, 4)
    }

    private static func buildDateURL(for date: Date) -> URL {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateString = formatter.string(from: date)
        return URL(string: "tscalendardemo://calendar?date=\(dateString)")!
    }
}

#if DEBUG
import WidgetKit

#Preview(as: .systemLarge) {
    WidgetDemo()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
}
#endif
