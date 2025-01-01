//
//  WidgetDemo.swift
//  WidgetDemo
//
//  Created by TAE SU LEE on 12/26/24.
//

import WidgetKit
import SwiftUI
import TSCalendar

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct WidgetDemoEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily // 위젯 크기 확인
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            WidgetSmallView() // 작은 크기에 사용할 뷰
        case .systemMedium:
            WidgetMediumView() // 중간 크기에 사용할 뷰
        case .systemLarge:
            WidgetLargeView() // 큰 크기에 사용할 뷰
//        case .accessoryRectangular:
//            AccessoryRectangularView() // Lock Screen 위젯 등 추가 지원
//        case .accessoryCircular:
//            AccessoryCircularView() // 원형 Lock Screen 위젯 등 추가 지원
        default:
            Text("Unsupported widget size")
        }
    }
}

struct WidgetDemo: Widget {
    let kind: String = "WidgetDemo"

    var body: some WidgetConfiguration {
        if #available(iOSApplicationExtension 15.0, *) {
            return createWidgetConfiguration().contentMarginsDisabled()
        } else {
            return createWidgetConfiguration()
        }
    }
    
    func createWidgetConfiguration() -> some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetDemoEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetDemoEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

//#Preview(as: .systemSmall) {
//    WidgetDemo()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}

#Preview(as: .systemSmall) {
    WidgetDemo()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
