//
//  TSCalendarMonthView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct TSCalendarMonthView: View {
    let monthData: [[TSCalendarDate]]
    let viewModel: TSCalendarViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(monthData.indices, id: \.self) { weekIndex in
                TSCalendarWeekView(
                    weekData: monthData[weekIndex],
                    viewModel: viewModel
                )
                .frame(height: viewModel.config.heightStyle.height)
            }
        }
    }
}
