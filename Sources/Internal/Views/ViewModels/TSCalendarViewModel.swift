//
//  TSCalendarViewModel.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import Combine
import SwiftUI

public final class TSCalendarViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var displayedDates: [Date] = []
    @Published private(set) var datesData: [[[TSCalendarDate]]] = []
    @Published private(set) var currentHeight: CGFloat?

    /// 애니메이션 트리거: 1 = next, -1 = previous, nil = 대기 중
    @Published var pendingAnimatedMove: Int?

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

        self.displayedDates =
            config.isPagingEnabled ? getDisplayedDates(from: initialDate) : [initialDate]
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
        guard
            let nextDate = calendar.date(
                byAdding: component, value: value, to: currentDisplayedDate),
            canMove(to: nextDate)
        else { return }

        displayedDates = config.isPagingEnabled ? getDisplayedDates(from: nextDate) : [nextDate]
        handleDateSelection(for: nextDate)
        generateAllDates()
        delegate?.calendar(pageDidChange: currentDisplayedDate)
    }

    func willMoveDate(by value: Int) {
        let component = config.displayMode == .month ? Calendar.Component.month : .weekOfYear
        guard
            let nextDate = calendar.date(
                byAdding: component, value: value, to: currentDisplayedDate),
            canMove(to: nextDate)
        else { return }

        delegate?.calendar(pageWillChange: nextDate)
        updateHeight(for: nextDate, animated: true)
    }

    func moveTo(date: Date, animated: Bool = true) {
        let normalizedDate = calendar.startOfDay(for: date)

        guard canMove(to: normalizedDate) else {
            return
        }

        switch config.displayMode {
        case .month:
            let currentMonth = calendar.component(.month, from: currentDisplayedDate)
            let currentYear = calendar.component(.year, from: currentDisplayedDate)

            let targetMonth = calendar.component(.month, from: normalizedDate)
            let targetYear = calendar.component(.year, from: normalizedDate)

            // 연도 및 월 비교
            if currentYear != targetYear || currentMonth != targetMonth {
                let yearDiff = targetYear - currentYear
                let monthDiff = (yearDiff * 12) + (targetMonth - currentMonth)

                // 1개월 이동이고 애니메이션 활성화 시 슬라이드 애니메이션
                if animated && abs(monthDiff) == 1 {
                    pendingAnimatedMove = monthDiff > 0 ? 1 : -1
                } else {
                    // 여러 개월 이동 또는 애니메이션 비활성화 시 즉시 이동
                    willMoveDate(by: monthDiff)
                    moveDate(by: monthDiff)
                }
            }
            // 같은 월이면 이미 표시 중이므로 이동 불필요

        case .week:
            let currentWeek = calendar.component(.weekOfYear, from: currentDisplayedDate)
            let currentYear = calendar.component(.yearForWeekOfYear, from: currentDisplayedDate)

            let targetWeek = calendar.component(.weekOfYear, from: normalizedDate)
            let targetYear = calendar.component(.yearForWeekOfYear, from: normalizedDate)

            // 연도 및 주차 비교
            if currentYear != targetYear || currentWeek != targetWeek {
                // 주차 차이 계산 (정확한 계산을 위해 날짜 기반으로 계산)
                let weekDiff = calculateWeekDifference(from: currentDisplayedDate, to: normalizedDate)

                // 1주 이동이고 애니메이션 활성화 시 슬라이드 애니메이션
                if animated && abs(weekDiff) == 1 {
                    pendingAnimatedMove = weekDiff > 0 ? 1 : -1
                } else {
                    // 여러 주 이동 또는 애니메이션 비활성화 시 즉시 이동
                    willMoveDate(by: weekDiff)
                    moveDate(by: weekDiff)
                }
            }
            // 같은 주면 이미 표시 중이므로 이동 불필요
        }
    }

    private func calculateWeekDifference(from startDate: Date, to endDate: Date) -> Int {
        let startWeek = getCurrentWeek(from: startDate)
        let endWeek = getCurrentWeek(from: endDate)

        let components = calendar.dateComponents([.weekOfYear], from: startWeek, to: endWeek)
        return components.weekOfYear ?? 0
    }

    func moveDay(by days: Int, animated: Bool = true) {
        // 라이브러리가 관리하는 selectedDate를 기준으로 계산
        let baseDate = selectedDate ?? Date()
        guard let targetDate = calendar.date(byAdding: .day, value: days, to: baseDate),
              canMove(to: targetDate)
        else { return }

        // 선택 날짜 내부적으로만 변경 (delegate 호출 안 함)
        selectedDate = targetDate

        // 월 경계 체크
        let currentMonth = calendar.component(.month, from: currentDisplayedDate)
        let targetMonth = calendar.component(.month, from: targetDate)
        let isSameMonth = currentMonth == targetMonth

        if isSameMonth {
            // 같은 달: 항상 즉시 업데이트 (animated 무시)
            generateAllDates()
        } else {
            // 월 경계: animated 파라미터에 따라
            moveTo(date: targetDate, animated: animated)
            if !animated {
                generateAllDates()
            }
        }
    }

    func moveMonth(by months: Int, animated: Bool = true) {
        // 월 이동은 현재 표시된 날짜 기준으로 계산
        let baseDate = currentDisplayedDate
        guard let targetDate = calendar.date(byAdding: .month, value: months, to: baseDate),
              canMove(to: targetDate)
        else { return }

        // autoSelect가 켜져 있으면 선택 로직 적용
        if config.autoSelect {
            let today = Date()
            if calendar.isDate(targetDate, equalTo: today, toGranularity: .month) {
                // 현재 달이면 오늘 선택
                selectedDate = calendar.startOfDay(for: today)
            } else {
                // 다른 달이면 1일 선택
                selectedDate = calendar.startOfMonth(for: targetDate)
            }
        }
        // autoSelect가 꺼져 있으면 selectedDate 변경 없음

        moveTo(date: targetDate, animated: animated)

        // animated=false일 때만 즉시 generateAllDates 호출
        // animated=true일 때는 애니메이션 완료 후 moveDate()에서 자동 호출
        if !animated {
            generateAllDates()
        }
    }

    func selectDate(_ date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)

        guard canMove(to: normalizedDate) else { return }
        selectedDate = normalizedDate

        let currentMonth = calendar.component(.month, from: currentDisplayedDate)
        let currentYear = calendar.component(.year, from: currentDisplayedDate)

        let selectedMonth = calendar.component(.month, from: normalizedDate)
        let selectedYear = calendar.component(.year, from: normalizedDate)

        // 연도 및 월 비교
        if currentYear != selectedYear || currentMonth != selectedMonth {
            let yearDiff = selectedYear - currentYear
            let monthDiff = (yearDiff * 12) + (selectedMonth - currentMonth)

            willMoveDate(by: monthDiff)
            moveDate(by: monthDiff)
        } else {
            generateAllDates()
        }

        delegate?.calendar(didSelect: normalizedDate)
    }

    func weekNumberOfYear(for date: Date) -> Int {
        return calendar.component(.weekOfYear, from: date)
    }

    func getPageHeight(at index: Int) -> CGFloat {
        guard case let .fixed(height) = config.heightStyle,
            let data = datesData[safe: index]
        else { return Self.defaultWeekHeight }

        switch config.displayMode {
        case .month:
            return CGFloat(data.count) * height
        case .week:
            return height
        }
    }
}

// MARK: - Height Calculation
extension TSCalendarViewModel {
    fileprivate static func calculateHeight(for date: Date, config: TSCalendarConfig) -> CGFloat? {
        guard case let .fixed(height) = config.heightStyle else { return nil }

        switch config.displayMode {
        case .month:
            let weeksCount = calculateWeeksCount(for: date, config: config)
            return height * CGFloat(weeksCount)
        case .week:
            return height
        }
    }

    fileprivate static func calculateWeeksCount(for date: Date, config: TSCalendarConfig) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let startOfMonth = calendar.startOfMonth(for: date)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let firstOffset = ((firstWeekday - 1) - config.startWeekDay.rawValue + 7) % 7
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30

        return config.monthStyle == .fixed ? 6 : Int(ceil(Double(firstOffset + daysInMonth) / 7.0))
    }

    fileprivate func updateHeight(for date: Date, animated: Bool = false) {
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
extension TSCalendarViewModel {
    fileprivate func generateAllDates() {
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

    fileprivate func getDisplayedDates(from date: Date) -> [Date] {
        let current =
            config.displayMode == .month
            ? calendar.startOfMonth(for: date) : getCurrentWeek(from: date)
        let component = config.displayMode == .month ? Calendar.Component.month : .weekOfYear
        return [-1, 0, 1].compactMap { offset in
            calendar.date(byAdding: component, value: offset, to: current)
        }
    }

    fileprivate func getCurrentWeek(from date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }

    fileprivate func generateDaysForMonth(_ month: Date) -> [[TSCalendarDate]] {
        let startOfMonth = calendar.startOfMonth(for: month)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let firstOffset = ((firstWeekday - 1) - config.startWeekDay.rawValue + 7) % 7
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 30

        let weeksNeeded =
            config.monthStyle == .fixed ? 6 : Int(ceil(Double(firstOffset + daysInMonth) / 7.0))
        let totalDays = weeksNeeded * 7

        let dates = (-firstOffset..<(totalDays - firstOffset)).compactMap {
            offset -> TSCalendarDate? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfMonth) else {
                return nil
            }

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

    fileprivate func generateDaysForWeek(_ weekStart: Date) -> [TSCalendarDate] {
        let firstWeekday = calendar.component(.weekday, from: weekStart)
        let startOffset = ((firstWeekday - 1) - config.startWeekDay.rawValue + 7) % 7
        let adjustedWeekStart =
            calendar.date(byAdding: .day, value: -startOffset, to: weekStart) ?? weekStart

        return (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: adjustedWeekStart)
            else { return nil }
            let currentMonth = displayedDates[safe: 0] ?? .now

            return TSCalendarDate(
                date: date,
                isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                isToday: calendar.isDateInToday(date),
                isInCurrentMonth: calendar.isDate(
                    date, equalTo: currentMonth, toGranularity: .month)
            )
        }
    }
}

// MARK: - Private Helpers
extension TSCalendarViewModel {
    fileprivate func handleDateSelection(for nextDate: Date) {
        guard config.autoSelect else { return }

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
        }
        // Note: delegate 호출 제거 - selectDate()에서만 호출하여 중복 방지
    }
}
