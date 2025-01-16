//
//  TSCalendarViewModel.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI
import Combine

final class TSCalendarViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var displayedDates: [Date] = []
    @Published private(set) var datesData: [[[TSCalendarDate]]] = []
    @Published private(set) var currentHeight: CGFloat?
    
    // MARK: - Properties
    private let calendar = Calendar(identifier: .gregorian)
    private let minimumDate: Date?
    private let maximumDate: Date?
    private(set) var selectedDate: Date?
    let config: TSCalendarConfig
    private let disableSwiftUIAnimation: Bool
    
    private(set) weak var delegate: TSCalendarDelegate?
    private(set) weak var dataSource: TSCalendarDataSource?
    private var cancellables = Set<AnyCancellable>()
    private var configCancellable: AnyCancellable?
    
    private static let defaultWeekHeight: CGFloat = 60.0
    private static let animationDuration: TimeInterval = 0.3

    // MARK: - Computed Properties
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
    
    // MARK: - Initialization
    init(
        initialDate: Date = .now,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        config: TSCalendarConfig = .init(),
        delegate: TSCalendarDelegate? = nil,
        dataSource: TSCalendarDataSource? = nil,
        disableSwiftUIAnimation: Bool = false
    ) {
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.selectedDate = selectedDate
        self.config = config
        self.delegate = delegate
        self.dataSource = dataSource
        self.disableSwiftUIAnimation = disableSwiftUIAnimation
        
        self.displayedDates = config.isPagingEnabled ? getDisplayedDates(from: initialDate) : [initialDate]
        generateAllDates()
        updateHeight(for: initialDate)
    }
}

// MARK: - Public Methods
extension TSCalendarViewModel {
    func canMove(to date: Date) -> Bool {
        if let minDate = minimumDate, date < minDate { return false }
        if let maxDate = maximumDate, date > maxDate { return false }
        return true
    }
    
    func moveDate(by value: Int) {
        let component = config.displayMode == .month ? Calendar.Component.month : .weekOfYear
        guard let nextDate = calendar.date(byAdding: component, value: value, to: currentDisplayedDate),
              canMove(to: nextDate) else { return }
        
        displayedDates = config.isPagingEnabled ? getDisplayedDates(from: nextDate) : [nextDate]
        handleDateSelection(for: nextDate)
        generateAllDates()
        delegate?.calendar(pageDidChange: currentDisplayedDate)
    }
    
    func willMoveDate(by value: Int) {
        let component = config.displayMode == .month ? Calendar.Component.month : .weekOfYear
        guard let nextDate = calendar.date(byAdding: component, value: value, to: currentDisplayedDate),
              canMove(to: nextDate) else { return }
        
        delegate?.calendar(pageWillChange: nextDate)
        updateHeight(for: nextDate, animated: true)
    }
    
    func selectDate(_ date: Date) {
        guard canMove(to: date) else { return }
        selectedDate = date
//        generateAllDates()
        delegate?.calendar(didSelect: date)
    }
    
    func weekNumberOfYear(for date: Date) -> Int {
        return calendar.component(.weekOfYear, from: date)
    }
    
    func getPageHeight(at index: Int) -> CGFloat {
        guard case let .fixed(height) = config.heightStyle,
              let data = datesData[safe: index] else { return Self.defaultWeekHeight }
        
        switch config.displayMode {
        case .month:
            return CGFloat(data.count) * height
        case .week:
            return height
        }
    }
}

// MARK: - Height Calculation
private extension TSCalendarViewModel {
    static func calculateHeight(for date: Date, config: TSCalendarConfig) -> CGFloat? {
        guard case let .fixed(height) = config.heightStyle else { return nil }
        
        switch config.displayMode {
        case .month:
            let weeksCount = calculateWeeksCount(for: date, config: config)
            return height * CGFloat(weeksCount)
        case .week:
            return height
        }
    }
    
    static func calculateWeeksCount(for date: Date, config: TSCalendarConfig) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let startOfMonth = calendar.startOfMonth(for: date)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let firstOffset = ((firstWeekday - 1) - config.startWeekDay.rawValue + 7) % 7
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        
        return config.monthStyle == .fixed ? 6 : Int(ceil(Double(firstOffset + daysInMonth) / 7.0))
    }
    
    func updateHeight(for date: Date, animated: Bool = false) {
        let newHeight = Self.calculateHeight(for: date, config: config)
        let shouldAnimate = animated && !disableSwiftUIAnimation
        
        if shouldAnimate {
            withAnimation(.easeInOut(duration: Self.animationDuration)) {
                currentHeight = newHeight
            }
        } else {
            currentHeight = newHeight
        }
    }
}

// MARK: - Date Generation
private extension TSCalendarViewModel {
    func generateAllDates() {
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
    
    func getDisplayedDates(from date: Date) -> [Date] {
        let current = config.displayMode == .month ? calendar.startOfMonth(for: date) : getCurrentWeek(from: date)
        let component = config.displayMode == .month ? Calendar.Component.month : .weekOfYear
        return [-1, 0, 1].compactMap { offset in
            calendar.date(byAdding: component, value: offset, to: current)
        }
    }
    
    func getCurrentWeek(from date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    func generateDaysForMonth(_ month: Date) -> [[TSCalendarDate]] {
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
    
    func generateDaysForWeek(_ weekStart: Date) -> [TSCalendarDate] {
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
}

// MARK: - Private Helpers
private extension TSCalendarViewModel {
    func handleDateSelection(for nextDate: Date) {
        guard config.autoSelectToday else { return }
        
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
}
