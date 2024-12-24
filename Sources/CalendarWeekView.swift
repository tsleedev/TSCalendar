//
//  CalendarWeekView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct CalendarWeekView: View {
    let weekData: [CalendarDate]
    let viewModel: CalendarViewModel
    
    var body: some View {
        ZStack {
            // 기본 주간 뷰
            HStack(spacing: 0) {
                ForEach(weekData) { date in
                    CalendarDayView(calendarDate: date, viewModel: viewModel)
                }
            }
            
            // 커스텀 영역
            if let firstDate = weekData.first?.date,
               let lastDate = weekData.last?.date {
                GeometryReader { geometry in
                    let _ = viewModel.dataSource?.calendar(weekView: self, 
                                                         startDate: firstDate, 
                                                         endDate: lastDate)
                }
            }
        }
    }
}
