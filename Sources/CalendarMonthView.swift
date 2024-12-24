//
//  CalendarMonthView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct CalendarMonthView: View {
    let monthData: [[CalendarDate]]
    let viewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(monthData.indices, id: \.self) { weekIndex in
                CalendarWeekView(
                    weekData: monthData[weekIndex],
                    viewModel: viewModel
                )
            }
        }
    }
}
