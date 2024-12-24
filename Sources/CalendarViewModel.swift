//
//  CalendarViewModel.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date?
    @Published var displayedMonths: [Date] = []  // 이전 달, 현재 달, 다음 달
    @Published var monthsData: [[[CalendarDate]]] = []  // 각 월의 날짜 데이터
    
    private let calendar = Calendar(identifier: .gregorian)
    private let minimumDate: Date
    private let maximumDate: Date
    
    weak var delegate: CalendarDelegate?
    var dataSource: CalendarDataSource?
    
    init(initialDate: Date = Date(),
         minimumDate: Date,
         maximumDate: Date,
         delegate: CalendarDelegate? = nil,
         dataSource: CalendarDataSource? = nil) {
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.delegate = delegate
        self.dataSource = dataSource
        
        // 현재 달과 이전, 다음 달 설정
        let currentMonth = calendar.startOfMonth(for: initialDate)
        if let prevMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth),
           let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            self.displayedMonths = [prevMonth, currentMonth, nextMonth]
        }
        
        generateAllMonthsDays()
    }
    
    func moveMonth(by value: Int) {
        delegate?.calendar(pageWillChange: displayedMonths[1])
        
        var newMonths = displayedMonths
        if value > 0 {
            if let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonths[2]) {
                newMonths.removeFirst()
                newMonths.append(newMonth)
            }
        } else {
            if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonths[0]) {
                newMonths.removeLast()
                newMonths.insert(newMonth, at: 0)
            }
        }
        
        displayedMonths = newMonths
        generateAllMonthsDays()
        
        delegate?.calendar(pageDidChange: displayedMonths[1])
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
        generateAllMonthsDays()
        delegate?.calendar(didSelect: date)
    }
    
    private func generateAllMonthsDays() {
        monthsData = displayedMonths.map { generateDaysForMonth($0) }
    }
    
    private func generateDaysForMonth(_ month: Date) -> [[CalendarDate]] {
        let startOfMonth = calendar.startOfMonth(for: month)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)!.count
        
        var allDays: [CalendarDate] = []
        
        // 이전 달의 날짜들
        let daysFromPreviousMonth = firstWeekday - 1
        if daysFromPreviousMonth > 0 {
            if let prevMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth) {
                let prevMonthDays = calendar.range(of: .day, in: .month, for: prevMonth)!.count
                for day in (prevMonthDays - daysFromPreviousMonth + 1)...prevMonthDays {
                    if let date = calendar.date(bySetting: .day, value: day, of: prevMonth) {
                        allDays.append(CalendarDate(date: date, isInCurrentMonth: false))
                    }
                }
            }
        }
        
        // 현재 달의 날짜들
        for day in 1...daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: month) {
                let isToday = calendar.isDateInToday(date)
                let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
                allDays.append(CalendarDate(date: date, isSelected: isSelected, isToday: isToday, isInCurrentMonth: true))
            }
        }
        
        // 다음 달의 날짜들
        let remainingDays = 42 - allDays.count  // 6주 * 7일 = 42
        if remainingDays > 0 {
            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) {
                for day in 1...remainingDays {
                    if let date = calendar.date(bySetting: .day, value: day, of: nextMonth) {
                        allDays.append(CalendarDate(date: date, isInCurrentMonth: false))
                    }
                }
            }
        }
        
        // 주 단위로 분리
        return stride(from: 0, to: allDays.count, by: 7).map {
            Array(allDays[$0..<min($0 + 7, allDays.count)])
        }
    }
}
