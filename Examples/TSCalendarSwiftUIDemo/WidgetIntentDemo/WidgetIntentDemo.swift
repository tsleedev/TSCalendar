//
//  WidgetIntentDemo.swift
//  WidgetIntentDemo
//
//  Created by TAE SU LEE on 12/27/24.
//

import WidgetKit
import SwiftUI
import TSCalendar

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct WidgetIntentDemoEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily // 위젯 크기 확인
    let calendar = Calendar.current
    var entry: Provider.Entry
    
    @StateObject private var controller = CalendarController()
    
    var body: some View {
        VStack(spacing: 0) {
//            Text(controller.headerTitle)
//                .font(.system(size: 12, weight: .semibold))
//                .padding(.horizontal, 16)
//                .padding(.vertical, 4)
//                .frame(maxWidth: .infinity, alignment: .leading)
            switch widgetFamily {
            case .systemSmall:
                TSCalendar(
                    initialDate: calendar.date(
                        byAdding: .month,
                        value: entry.configuration.selectedOffset.rawValue,
                        to: .now
                    ) ?? .now,
                    config: .init(
                        autoSelectToday: false,
                        displayMode: .week,
                        isPagingEnabled: false,
                        showHeader: false
                    ),
                    appearance: TSCalendarAppearance(type: .widget(.small))
                )
            case .systemMedium:
                TSCalendar(
                    initialDate: calendar.date(
                        byAdding: .month,
                        value: entry.configuration.selectedOffset.rawValue,
                        to: .now
                    ) ?? .now,
                    config: .init(
                        autoSelectToday: false,
                        displayMode: .week,
                        isPagingEnabled: false,
//                        showHeader: false
                        showWeekNumber: true
                    ),
                    appearance: TSCalendarAppearance(type: .widget(.medium)),
                    delegate: controller,
                    dataSource: controller
                )
            case .systemLarge:
                TSCalendar(
                    initialDate: calendar.date(
                        byAdding: .month,
                        value: entry.configuration.selectedOffset.rawValue,
                        to: .now
                    ) ?? .now,
                    config: .init(
                        autoSelectToday: false,
                        displayMode: .month,
                        isPagingEnabled: false,
//                        showHeader: false
                        showWeekNumber: true
                    ),
                    appearance: TSCalendarAppearance(type: .widget(.large)),
                    delegate: controller,
                    dataSource: controller
                )
            default:
                Text("Unsupported widget size")
            }
        }
    }
}

struct WidgetIntentDemo: Widget {
    let kind: String = "WidgetIntentDemo"
    
    var body: some WidgetConfiguration {
        if #available(iOSApplicationExtension 15.0, *) {
            return createWidgetConfiguration().contentMarginsDisabled()
        } else {
            return createWidgetConfiguration()
        }
    }
    
    func createWidgetConfiguration() -> some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetIntentDemoEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetIntentDemoEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var current: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.selectedOffset = .current
        return intent
    }
    
    fileprivate static var minus1: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.selectedOffset = .minus1
        return intent
    }
}

#Preview(as: .systemLarge) {
    WidgetIntentDemo()
} timeline: {
    SimpleEntry(date: .now, configuration: .current)
    SimpleEntry(date: .now, configuration: .minus1)
}
