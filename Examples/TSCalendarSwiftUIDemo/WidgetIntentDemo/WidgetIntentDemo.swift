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

    /// 현재 표시할 월의 offset (UserDefaults에서 읽음)
    private var currentOffset: Int {
        WidgetNavigationStorage.currentOffset
    }

    /// 표시할 날짜 계산
    private var displayDate: Date {
        calendar.date(byAdding: .month, value: currentOffset, to: .now) ?? .now
    }

    var body: some View {
        VStack(spacing: 0) {
            switch widgetFamily {
            case .systemSmall:
                // 스몰: 컴팩트 네비게이션 헤더 + 달력 + 이벤트 카운트
                smallNavigationHeader
                TSCalendar(
                    initialDate: displayDate,
                    config: .init(
                        autoSelectToday: false,
                        displayMode: .month,
                        eventDisplayStyle: .count,  // "+1", "+2" 형태로 이벤트 표시
                        isPagingEnabled: false,
                        showHeader: false,
                        showWeekNumber: true
                    ),
                    appearance: TSCalendarAppearance(type: .widget(.small)),
                    delegate: controller,
                    dataSource: controller
                )
            case .systemMedium:
                // 미디엄: 네비게이션 헤더 + 주 뷰
                navigationHeader
                TSCalendar(
                    initialDate: displayDate,
                    config: .init(
                        autoSelectToday: false,
                        displayMode: .week,
                        isPagingEnabled: false,
                        showHeader: false,
                        showWeekNumber: true
                    ),
                    appearance: TSCalendarAppearance(type: .widget(.medium)),
                    delegate: controller,
                    dataSource: controller
                )
            case .systemLarge:
                // 라지: 네비게이션 헤더 + 월 뷰
                navigationHeader
                TSCalendar(
                    initialDate: displayDate,
                    config: .init(
                        autoSelectToday: false,
                        displayMode: .month,
                        isPagingEnabled: false,
                        showHeader: false,
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

    /// 스몰 위젯용 컴팩트 네비게이션 헤더
    private var smallNavigationHeader: some View {
        HStack {
            Button(intent: NavigatePreviousIntent()) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .semibold))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(intent: NavigateTodayIntent()) {
                Text(shortHeaderTitle)
                    .font(.system(size: 10, weight: .semibold))
            }
            .buttonStyle(.plain)

            Spacer()

            Button(intent: NavigateNextIntent()) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .frame(height: 20)
    }

    /// 네비게이션 헤더
    private var navigationHeader: some View {
        HStack {
            Button(intent: NavigatePreviousIntent()) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(intent: NavigateTodayIntent()) {
                Text(headerTitle)
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)

            Spacer()

            Button(intent: NavigateNextIntent()) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .frame(height: 36)
    }

    /// 헤더 타이틀 생성
    private var headerTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMM yyyy",
            options: 0,
            locale: Locale.current
        )
        return formatter.string(from: displayDate)
    }

    /// 스몰 위젯용 짧은 헤더 타이틀 (Nov 2025)
    private var shortHeaderTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMM yyyy",
            options: 0,
            locale: Locale.current
        )
        return formatter.string(from: displayDate)
    }
}

struct WidgetIntentDemo: Widget {
    let kind: String = "WidgetIntentDemo"
    
    var body: some WidgetConfiguration {
        createWidgetConfiguration().contentMarginsDisabled()
    }

    func createWidgetConfiguration() -> some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WidgetIntentDemoEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
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
