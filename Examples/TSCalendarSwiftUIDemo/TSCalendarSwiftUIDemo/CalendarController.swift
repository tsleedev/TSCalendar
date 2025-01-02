//
//  CalendarController.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 12/26/24.
//

import SwiftUI
import TSCalendar

class CalendarController: ObservableObject, TSCalendarDelegate, TSCalendarDataSource {
    @Published var displayMode: TSCalendarDisplayMode = .month
    @Published var scrollDirection: TSCalendarScrollDirection = .horizontal
    @Published var startWeekDay: TSCalendarStartWeekDay = .sunday
    
    var events: [TSCalendarEvent] = [
        // 첫째 주 이벤트 (겹치게 설정)
        TSCalendarEvent(
            title: "첫째 주 이벤트 1",
            startDate: createDate(monthOffset: .current, day: 1),
            endDate: createDate(monthOffset: .current, day: 2),
            backgroundColor: .orange,
            textColor: .white
        ),
        TSCalendarEvent(
            title: "첫째 주 이벤트 2",
            startDate: createDate(monthOffset: .current, day: 2),
            endDate: createDate(monthOffset: .current, day: 3),
            backgroundColor: .blue,
            textColor: .white
        ),
        TSCalendarEvent(
            title: "첫째 주 이벤트 3",
            startDate: createDate(monthOffset: .current, day: 1),
            endDate: createDate(monthOffset: .current, day: 3),
            backgroundColor: .green,
            textColor: .white
        ),
        TSCalendarEvent(
            title: "첫째 주 이벤트 4",
            startDate: createDate(monthOffset: .current, day: 2),
            endDate: createDate(monthOffset: .current, day: 5),
            backgroundColor: .purple,
            textColor: .white
        ),
        TSCalendarEvent(
            title: "첫째 주 이벤트 5",
            startDate: createDate(monthOffset: .current, day: 3),
            endDate: createDate(monthOffset: .current, day: 4),
            backgroundColor: .red,
            textColor: .white
        ),
        
        // 이전 달에서 넘어온 이벤트
        TSCalendarEvent(
            title: "지난달에서 넘어온 이벤트",
            startDate: createDate(monthOffset: .previous, day: 28),
            endDate: createDate(monthOffset: .current, day: 2),
            backgroundColor: .brown,
            textColor: .white
        ),
        
        // 다음 달로 넘어가는 이벤트
        TSCalendarEvent(
            title: "다음달로 넘어가는 이벤트",
            startDate: createDate(monthOffset: .current, day: 28),
            endDate: createDate(monthOffset: .next, day: 3),
            backgroundColor: .cyan,
            textColor: .white
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
