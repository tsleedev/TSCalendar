//
//  CalendarController.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 12/27/24.
//

import SwiftUI
import TSCalendar

class CalendarController: ObservableObject, TSCalendarDelegate, TSCalendarDataSource {
    @Published var displayMode: TSCalendarDisplayMode = .month
    @Published var scrollDirection: TSCalendarScrollDirection = .horizontal
    @Published var startWeekDay: TSCalendarStartWeekDay = .sunday
    
    var events: [TSCalendarEvent] = [
        TSCalendarEvent(
            title: "테스트",
            startDate: createDate(2024, 12, 1),
            endDate: createDate(2024, 12, 2),
            backgroundColor: .green,
            textColor: .white
        ),
        TSCalendarEvent(
            title: "111",
            startDate: createDate(2024, 12, 1),
            endDate: createDate(2024, 12, 2),
            backgroundColor: .orange,
            textColor: .white
        ),
        TSCalendarEvent(
            title: "222",
            startDate: createDate(2024, 12, 2),
            endDate: createDate(2024, 12, 2),
            backgroundColor: .orange,
            textColor: .white
        ),
        TSCalendarEvent(
            title: "3333333",
            startDate: createDate(2024, 12, 1),
            endDate: createDate(2024, 12, 1),
            backgroundColor: .orange,
            textColor: .white
        ),
        TSCalendarEvent(
            title: "444",
            startDate: createDate(2024, 12, 1),
            endDate: createDate(2024, 12, 1),
            backgroundColor: .orange,
            textColor: .white
        ),
        TSCalendarEvent(
            title: "555",
            startDate: createDate(2024, 12, 1),
            endDate: createDate(2024, 12, 2),
            backgroundColor: .orange,
            textColor: .white
        ),
        TSCalendarEvent(
            title: "생일생일생일",
            startDate: createDate(2024, 12, 3),
            endDate: createDate(2024, 12, 3),
            backgroundColor: .red,
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
    private static func createDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}
