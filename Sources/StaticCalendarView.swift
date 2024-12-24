//
//  StaticCalendarView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

// Widget에서 사용할 정적 달력 뷰
struct StaticCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarMonthView(monthData: viewModel.monthsData[1],
                     viewModel: viewModel)
                .transition(.opacity)
        }
    }
}
