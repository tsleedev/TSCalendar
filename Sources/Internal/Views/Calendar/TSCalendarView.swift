//
//  TSCalendarView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct TSCalendarView: View {
    @StateObject private var viewModel: TSCalendarViewModel
    private let environment: TSCalendarEnvironment
    private let startWeekDay: TSCalendarStartWeekDay
    
    init(
        initialDate: Date = .now,
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
        _viewModel = StateObject(wrappedValue: TSCalendarViewModel(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate,
            displayMode: displayMode,
            scrollDirection: scrollDirection,
            startWeekDay: startWeekDay,
            environment: environment,
            delegate: delegate,
            dataSource: dataSource
        ))
        self.environment = environment
        self.startWeekDay = startWeekDay
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TSCalendarMonthHeaderView(
                viewModel: viewModel,
                environment: environment
            )
            TSCalendarWeekdayHeaderView(startWeekDay: startWeekDay)
            
            if environment.isPagingEnabled {
                TSCalendarPagingView(viewModel: viewModel)
            } else {
                TSCalendarStaticView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    TSCalendarView(
        minimumDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()),
        maximumDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
        selectedDate: Date(),
        displayMode: .month,
        scrollDirection: .vertical,
        environment: .app
    )
}
