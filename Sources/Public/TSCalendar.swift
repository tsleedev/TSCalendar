//
//  TSCalendar.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

public struct TSCalendar: View {
    private let initialDate: Date
    private let minimumDate: Date?
    private let maximumDate: Date?
    private let selectedDate: Date?
    private let displayMode: TSCalendarDisplayMode
    private let scrollDirection: TSCalendarScrollDirection
    private let startWeekDay: TSCalendarStartWeekDay
    private let showWeekNumber: Bool
    private let environment: TSCalendarEnvironment
    private let appearanceType: TSCalendarAppearanceType
    private let delegate: TSCalendarDelegate?
    private let dataSource: TSCalendarDataSource?
    
    public init(
        initialDate: Date = .now,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        displayMode: TSCalendarDisplayMode = .month,
        scrollDirection: TSCalendarScrollDirection = .vertical,
        startWeekDay: TSCalendarStartWeekDay = .sunday,
        showWeekNumber: Bool = false,
        environment: TSCalendarEnvironment = .app,
        appearanceType: TSCalendarAppearanceType = .app,
        delegate: TSCalendarDelegate? = nil,
        dataSource: TSCalendarDataSource? = nil
    ) {
        self.initialDate = initialDate
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.selectedDate = selectedDate
        self.displayMode = displayMode
        self.scrollDirection = scrollDirection
        self.startWeekDay = startWeekDay
        self.showWeekNumber = showWeekNumber
        self.environment = environment
        self.appearanceType = appearanceType
        self.delegate = delegate
        self.dataSource = dataSource
    }
    
    public var body: some View {
        TSCalendarView(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate,
            displayMode: displayMode,
            scrollDirection: scrollDirection,
            startWeekDay: startWeekDay,
            showWeekNumber: showWeekNumber,
            environment: environment,
            delegate: delegate,
            dataSource: dataSource
        )
        .environment(\.calendarAppearance, TSCalendarAppearance(type: appearanceType))
        .id("\(displayMode)_\(scrollDirection)_\(startWeekDay)_\(showWeekNumber)") // 설정 변경 시 새로 그리기
    }
}
