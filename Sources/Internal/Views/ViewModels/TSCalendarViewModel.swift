//
//  TSCalendarViewModel.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

final class TSCalendarViewModel: ObservableObject {
    @Published var selectedDate: Date?
    @Published var displayMode: TSCalendarDisplayMode
    @Published var scrollDirection: TSCalendarScrollDirection
    @Published var displayedDates: [Date] = []
    @Published var datesData: [[[TSCalendarDate]]] = []
    
    private let calendar = Calendar(identifier: .gregorian)
    private let minimumDate: Date?
    private let maximumDate: Date?
    private let startWeekDay: TSCalendarStartWeekDay
    private let environment: TSCalendarEnvironment
    
    weak var delegate: TSCalendarDelegate?
    weak var dataSource: TSCalendarDataSource?
    
    init(
        initialDate: Date,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        displayMode: TSCalendarDisplayMode = .month,
        scrollDirection: TSCalendarScrollDirection = .horizontal,
        startWeekDay: TSCalendarStartWeekDay = .sunday,
        environment: TSCalendarEnvironment = .app,
        delegate: TSCalendarDelegate? = nil,
        dataSource: TSCalendarDataSource? = nil
    ) {
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.selectedDate = selectedDate
        self.scrollDirection = scrollDirection
        self.startWeekDay = startWeekDay
        self.displayMode = displayMode
        self.environment = environment
        self.delegate = delegate
        self.dataSource = dataSource
        
        self.displayedDates = environment.isPagingEnabled ? getDisplayedDates(from: initialDate) : [initialDate]
        generateAllDates()
    }
    
    private func getDisplayedDates(from date: Date) -> [Date] {
        let current = displayMode == .month ? calendar.startOfMonth(for: date) : getCurrentWeek(from: date)
        let component = displayMode == .month ? Calendar.Component.month : .weekOfYear
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
        let component = displayMode == .month ? Calendar.Component.month : .weekOfYear
        guard let nextDate = calendar.date(byAdding: component, value: value, to: displayedDates[1]),
              canMove(to: nextDate) else { return }
        
        delegate?.calendar(pageWillChange: displayedDates[1])
        displayedDates = environment.isPagingEnabled ?
        getDisplayedDates(from: nextDate) : [nextDate]
        
        if environment.autoSelectToday {
            let today = Date()
            if calendar.isDate(nextDate, equalTo: today, toGranularity: .month) {
                selectedDate = today
            } else {
                switch displayMode {
                case .month:
                    selectedDate = calendar.startOfMonth(for: nextDate)
                case .week:
                    selectedDate = getCurrentWeek(from: nextDate)
                }
                delegate?.calendar(didSelect: nextDate)
            }
        }
        
        generateAllDates()
        delegate?.calendar(pageDidChange: displayedDates[1])
    }
    
    func selectDate(_ date: Date) {
        guard canMove(to: date) else { return }
        selectedDate = date
        generateAllDates()
        delegate?.calendar(didSelect: date)
    }
    
    private func generateAllDates() {
        switch displayMode {
        case .month:
            if environment.isPagingEnabled {
                datesData = displayedDates.map { generateDaysForMonth($0) }
            } else {
                datesData = [generateDaysForMonth(displayedDates[0])]
            }
        case .week:
            if environment.isPagingEnabled {
                datesData = displayedDates.map { [generateDaysForWeek($0)] }
            } else {
                datesData = [[generateDaysForWeek(displayedDates[0])]]
            }
        }
    }
    
    private func getCurrentWeek(from date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    private func generateDaysForWeek(_ weekStart: Date) -> [TSCalendarDate] {
        let startOffset = (calendar.component(.weekday, from: weekStart) - startWeekDay.rawValue + 7) % 7
        let adjustedWeekStart = calendar.date(byAdding: .day, value: -startOffset, to: weekStart) ?? weekStart
        
        return (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: adjustedWeekStart) else { return nil }
            
            return TSCalendarDate(
                date: date,
                isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                isToday: calendar.isDateInToday(date),
                isInCurrentMonth: calendar.isDate(date, equalTo: displayedDates[0], toGranularity: .month)
            )
        }
    }
    
    private func generateDaysForMonth(_ month: Date) -> [[TSCalendarDate]] {
        let startOfMonth = calendar.startOfMonth(for: month)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let firstOffset = ((firstWeekday - 1) - startWeekDay.rawValue + 7) % 7
        
        let dates = (-firstOffset..<(42-firstOffset)).compactMap { offset -> TSCalendarDate? in
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