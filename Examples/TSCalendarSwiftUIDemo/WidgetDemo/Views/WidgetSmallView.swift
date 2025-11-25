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
            config: .init(
                displayMode: .month,
                eventDisplayStyle: .count,  // "+1", "+2" 형태로 이벤트 카운트 표시
                isPagingEnabled: false,     // 스몰 위젯에서 네비게이션 버튼 숨김
                showWeekNumber: true
            ),
            appearance: TSCalendarAppearance(type: .widget(.small)),
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
