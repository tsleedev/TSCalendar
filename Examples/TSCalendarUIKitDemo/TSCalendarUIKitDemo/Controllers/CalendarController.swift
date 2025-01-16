//
//  CalendarController.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 12/26/24.
//

import SwiftUI
import TSCalendar

final class CalendarController: ObservableObject, TSCalendarDelegate, TSCalendarDataSource {
    @Published private(set) var headerTitle: String = ""
    @Published var config: TSCalendarConfig
    
    init(config: TSCalendarConfig = .init()) {
        self.config = config
        self.headerTitle = getHeaderTitle(date: .now)
    }
    
    var events: [TSCalendarEvent] = [
        // 첫째 주 이벤트 (겹치게 설정)
        TSCalendarEvent(
            title: "첫째 주 이벤트 1",
            startDate: createDate(monthOffset: .current, day: 1),
            endDate: createDate(monthOffset: .current, day: 2),
            backgroundColor: Color.orange.opacity(0.15),
            textColor: .orange
        ),
        TSCalendarEvent(
            title: "첫째 주 이벤트 2",
            startDate: createDate(monthOffset: .current, day: 2),
            endDate: createDate(monthOffset: .current, day: 3),
            backgroundColor: Color.blue.opacity(0.15),
            textColor: .blue
        ),
        TSCalendarEvent(
            title: "첫째 주 이벤트 3",
            startDate: createDate(monthOffset: .current, day: 1),
            endDate: createDate(monthOffset: .current, day: 3),
            backgroundColor: Color.green.opacity(0.15),
            textColor: .green
        ),
        TSCalendarEvent(
            title: "첫째 주 이벤트 4",
            startDate: createDate(monthOffset: .current, day: 2),
            endDate: createDate(monthOffset: .current, day: 5),
            backgroundColor: Color.purple.opacity(0.15),
            textColor: .purple
        ),
        TSCalendarEvent(
            title: "첫째 주 이벤트 5",
            startDate: createDate(monthOffset: .current, day: 3),
            endDate: createDate(monthOffset: .current, day: 4),
            backgroundColor: Color.red.opacity(0.15),
            textColor: .red
        ),
        
        // 이전 달에서 넘어온 이벤트
        TSCalendarEvent(
            title: "지난달에서 넘어온 이벤트",
            startDate: createDate(monthOffset: .previous, day: 28),
            endDate: createDate(monthOffset: .current, day: 2),
            backgroundColor: Color.brown.opacity(0.15),
            textColor: .brown
        ),
        
        // 다음 달로 넘어가는 이벤트
        TSCalendarEvent(
            title: "다음달로 넘어가는 이벤트",
            startDate: createDate(monthOffset: .current, day: 28),
            endDate: createDate(monthOffset: .next, day: 3),
            backgroundColor: Color.cyan.opacity(0.15),
            textColor: .cyan
        )
    ]
    
    func calendar(date: Date) -> [TSCalendarEvent] {
        return events.filter { event in
            let calendar = Calendar.current
            return calendar.isDate(date, equalTo: event.startDate, toGranularity: .day) ||
            calendar.isDate(date, equalTo: event.endDate, toGranularity: .day) ||
            (date > event.startDate && date < event.endDate)
        }
    }
    
    func calendar(startDate: Date, endDate: Date) -> [TSCalendarEvent] {
        return events.filter { event in
            // 이벤트가 해당 기간과 겹치는지 확인
            !(event.endDate < startDate || event.startDate > endDate)
        }
    }
    
    func calendar(didSelect date: Date) {
        print("Selected date: \(date)")
    }
    
    func calendar(pageDidChange date: Date) {
        print("Page changed to: \(date)")
        headerTitle = getHeaderTitle(date: date)
    }
    
    private func getHeaderTitle(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMM yyyy",
            options: 0,
            locale: Locale.current
        )
        return dateFormatter.string(from: date)
    }
    
    // 날짜 생성 헬퍼 함수
    private enum MonthOffset: Int {
        case previous = -1
        case current = 0
        case next = 1
    }
    
    private static func createDate(monthOffset: MonthOffset, day: Int) -> Date {
        let calendar = Calendar.current
        let currentDate = Date()
        guard let offsetDate = calendar.date(byAdding: .month, value: monthOffset.rawValue, to: currentDate) else {
            return Date()
        }
        var components = calendar.dateComponents([.year, .month], from: offsetDate)
        components.day = day
        return calendar.date(from: components) ?? Date()
    }
}
