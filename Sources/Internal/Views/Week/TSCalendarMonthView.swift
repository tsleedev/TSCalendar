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
    let customization: TSCalendarCustomization?
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(monthData.indices, id: \.self) { weekIndex in
                content(for: monthData[weekIndex])
            }
        }
    }
    
    @ViewBuilder
    private func content(for weekData: [TSCalendarDate]) -> some View {
        if let customization = customization {
            customization.weekView?(
                weekData,
                { selectedDate in
                    viewModel.selectDate(selectedDate)
                }
            )
        } else {
            TSCalendarWeekView(
                weekData: weekData,
                viewModel: viewModel
            )
            .frame(height: viewModel.config.heightStyle.height)
        }
    }
}
