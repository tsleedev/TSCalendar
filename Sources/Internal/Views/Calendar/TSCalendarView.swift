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
    
    init(
        initialDate: Date = .now,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        config: TSCalendarConfig = .init(),
        delegate: TSCalendarDelegate? = nil,
        dataSource: TSCalendarDataSource? = nil
    ) {
        _viewModel = StateObject(wrappedValue: TSCalendarViewModel(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate,
            config: config,
            delegate: delegate,
            dataSource: dataSource
        ))
        self.config = config
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if config.showHeader {
                TSCalendarMonthHeaderView(
                    viewModel: viewModel
                )
            }
            TSCalendarWeekdayHeaderView(
                viewModel: viewModel
            )
            
            if config.isPagingEnabled {
                TSCalendarPagingView(viewModel: viewModel)
            } else {
                TSCalendarStaticView(viewModel: viewModel)
            }
        }
        .frame(maxHeight: config.heightStyle.height == nil ? .infinity : nil)
    }
}

#Preview {
    TSCalendarView(
        minimumDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()),
        maximumDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
        selectedDate: Date()
    )
}
