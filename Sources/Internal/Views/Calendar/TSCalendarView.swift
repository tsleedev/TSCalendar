//
//  TSCalendarView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct TSCalendarView: View {
    @StateObject private var viewModel: TSCalendarViewModel
    private let config: TSCalendarConfig
    private let environment: TSCalendarEnvironment
    
    init(
        initialDate: Date = .now,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        config: TSCalendarConfig = .init(),
        environment: TSCalendarEnvironment = .app,
        delegate: TSCalendarDelegate? = nil,
        dataSource: TSCalendarDataSource? = nil
    ) {
        _viewModel = StateObject(wrappedValue: TSCalendarViewModel(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate,
            config: config,
            environment: environment,
            delegate: delegate,
            dataSource: dataSource
        ))
        self.config = config
        self.environment = environment
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TSCalendarMonthHeaderView(
                viewModel: viewModel,
                environment: environment
            )
            TSCalendarWeekdayHeaderView(
                viewModel: viewModel
            )
            
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
        config: TSCalendarConfig(),
        environment: .app
    )
}
