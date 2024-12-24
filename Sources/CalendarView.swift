//
//  CalendarView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct CalendarView: View {
    enum Environment {
        case widget
        case app
    }
    
    @StateObject private var viewModel: CalendarViewModel
    private let environment: Environment
    
    init(initialDate: Date = Date(),
         minimumDate: Date,
         maximumDate: Date,
         delegate: CalendarDelegate? = nil,
         dataSource: CalendarDataSource? = nil,
         environment: Environment = .widget) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            delegate: delegate,
            dataSource: dataSource
        ))
        self.environment = environment
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarHeaderView(currentMonth: viewModel.displayedMonths[1]) {
                moveToPreviousMonth()
            } nextMonth: {
                moveToNextMonth()
            }
            
            CalendarWeekdayHeaderView()
            
            if environment == .widget {
                // Widget 환경에서는 단순 월별 보기
                StaticCalendarView(viewModel: viewModel)
            } else {
                // 앱 환경에서는 TabView 기반 페이징
                PagingCalendarView(viewModel: viewModel)
            }
        }
        .padding()
    }
    
    private func moveToPreviousMonth() {
        viewModel.moveMonth(by: -1)
    }
    
    private func moveToNextMonth() {
        viewModel.moveMonth(by: 1)
    }
}

#Preview {
    CalendarView(
        minimumDate: Date(),
        maximumDate: Date()
    )
}
