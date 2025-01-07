//
//  WidgetSmallView.swift
//  WidgetDemoExtension
//
//  Created by TAE SU LEE on 12/27/24.
//

import SwiftUI
import TSCalendar

struct WidgetSmallView: View {
    @StateObject private var controller = CalendarController()
    
    var body: some View {
        TSCalendar(
            config: .init(displayMode: .month),
            environment: .widget,
            appearanceType: .widget(.small),
            delegate: controller,
            dataSource: controller
        )
        .padding(.vertical, 4)
    }
}

#if DEBUG
import WidgetKit

#Preview(as: .systemSmall) {
    WidgetDemo()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
}
#endif
