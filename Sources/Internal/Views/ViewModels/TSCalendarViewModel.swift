//
//  TSCalendarViewModel.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

final class TSCalendarViewModel: ObservableObject {
    @Published private(set) var displayedDates: [Date] = []
    @Published private(set) var datesData: [[[TSCalendarDate]]] = []
    @Published private(set) var currentHeight: CGFloat?
    
    private let calendar = Calendar(identifier: .gregorian)
    private let minimumDate: Date?
    private let maximumDate: Date?
    private(set) var selectedDate: Date?
    let config: TSCalendarConfig
    
    private(set) weak var delegate: TSCalendarDelegate?
    private(set) weak var dataSource: TSCalendarDataSource?
    
    var currentDisplayedDate: Date {
        let index = config.isPagingEnabled ? 1 : 0
        return displayedDates[safe: index] ?? Date()
    }
    
    var currentCalendarData: [[TSCalendarDate]] {
        let index = config.isPagingEnabled ? 1 : 0
        return datesData[safe: index] ?? []
    }
    
    var currentWeekData: [TSCalendarDate] {
        let index = config.isPagingEnabled ? 1 : 0
        return datesData[safe: index]?.first ?? []
    }
    
    init(
        initialDate: Date,
        minimumDate: Date?,
        maximumDate: Date?,
        selectedDate: Date?,
        config: TSCalendarConfig,
        delegate: TSCalendarDelegate?,
        dataSource: TSCalendarDataSource?
    ) {
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.selectedDate = selectedDate
        self.config = config
        self.delegate = delegate
        self.dataSource = dataSource
        
        self.displayedDates = config.isPagingEnabled ? getDisplayedDates(from: initialDate) : [initialDate]
        generateAllDates()
    }
    
    private func getDisplayedDates(from date: Date) -> [Date] {
        let current = config.displayMode == .month ? calendar.startOfMonth(for: date) : getCurrentWeek(from: date)
        let component = config.displayMode == .month ? Calendar.Component.month : .weekOfYear
        return [-1, 0, 1].compactMap { offset in
            calendar.date(byAdding: component, value: offset, to: current)
        }
    }
    
    func canMove(to date: Date) -> Bool {
        if let minDate = minimumDate, date < minDate { return false }
        if let maxDate = maximumDate, date > maxDate { return false }
        return true
    }
    
    func moveDate(by value: Int) {
        let component = config.displayMode == .month ? Calendar.Component.month : .weekOfYear
        guard let currentDate = displayedDates[safe: 1],
              let nextDate = calendar.date(byAdding: component, value: value, to: currentDate),
              canMove(to: nextDate) else { return }
        
        delegate?.calendar(pageWillChange: currentDate)
        
        displayedDates = config.isPagingEnabled ? getDisplayedDates(from: nextDate) : [nextDate]
        
        // 다음 달의 높이를 계산
        if case let .fixed(height) = config.heightStyle {
            switch config.displayMode {
            case .month:
                let monthData = generateDaysForMonth(nextDate)
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentHeight = height * CGFloat(monthData.count)
                }
            case .week:
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentHeight = height  // 주 모드는 항상 한 주의 높이
                }
            }
        }
       
       if config.autoSelectToday {
           let today = Date()
           if calendar.isDate(nextDate, equalTo: today, toGranularity: .month) {
               selectedDate = today
           } else {
               switch config.displayMode {
               case .month:
                   selectedDate = calendar.startOfMonth(for: nextDate)
               case .week:
                   selectedDate = getCurrentWeek(from: nextDate)
               }
               delegate?.calendar(didSelect: nextDate)
           }
       }
       
       generateAllDates()
       delegate?.calendar(pageDidChange: currentDisplayedDate)
    }
    
    private func generateDatesData(for dates: [Date]) -> [[[TSCalendarDate]]] {
       dates.map { date in
           switch config.displayMode {
           case .month:
               return generateDaysForMonth(date)
           case .week:
               return [generateDaysForWeek(date)]
           }
       }
    }
    
    func weekNumberOfYear(for date: Date) -> Int {
        return calendar.component(.weekOfYear, from: date)
    }
    
    func selectDate(_ date: Date) {
        guard canMove(to: date) else { return }
        selectedDate = date
        generateAllDates()
        delegate?.calendar(didSelect: date)
    }
    
    private func generateAllDates() {
        switch config.displayMode {
        case .month:
            if config.isPagingEnabled {
                datesData = displayedDates.map { generateDaysForMonth($0) }
            } else {
                guard let date = displayedDates[safe: 0] else { return }
                datesData = [generateDaysForMonth(date)]
            }
        case .week:
            if config.isPagingEnabled {
                datesData = displayedDates.map { [generateDaysForWeek($0)] }
            } else {
                guard let date = displayedDates[safe: 0] else { return }
                datesData = [[generateDaysForWeek(date)]]
            }
        }
    }
    
    private func getCurrentWeek(from date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    private func generateDaysForWeek(_ weekStart: Date) -> [TSCalendarDate] {
        let firstWeekday = calendar.component(.weekday, from: weekStart)
        let startOffset = ((firstWeekday - 1) - config.startWeekDay.rawValue + 7) % 7
        let adjustedWeekStart = calendar.date(byAdding: .day, value: -startOffset, to: weekStart) ?? weekStart
        
        return (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: adjustedWeekStart) else { return nil }
            let currentMonth = displayedDates[safe: 0] ?? .now
            
            return TSCalendarDate(
                date: date,
                isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                isToday: calendar.isDateInToday(date),
                isInCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
            )
        }
    }
    
    private func generateDaysForMonth(_ month: Date) -> [[TSCalendarDate]] {
        let startOfMonth = calendar.startOfMonth(for: month)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let firstOffset = ((firstWeekday - 1) - config.startWeekDay.rawValue + 7) % 7
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
        
        let weeksNeeded = config.monthStyle == .fixed ? 6 : Int(ceil(Double(firstOffset + daysInMonth) / 7.0))
        let totalDays = weeksNeeded * 7
        
        let dates = (-firstOffset..<(totalDays-firstOffset)).compactMap { offset -> TSCalendarDate? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfMonth) else { return nil }
            
            return TSCalendarDate(
                date: date,
                isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                isToday: calendar.isDateInToday(date),
                isInCurrentMonth: calendar.isDate(date, equalTo: month, toGranularity: .month)
            )
        }
        
        return stride(from: 0, to: dates.count, by: 7).map {
            Array(dates[$0..<min($0 + 7, dates.count)])
        }
    }
}
