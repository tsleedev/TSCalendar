//
//  TSCalendarStaticView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

// Widget에서 사용할 정적 달력 뷰
struct TSCalendarStaticView: View {
    @ObservedObject var viewModel: TSCalendarViewModel
    let customization: TSCalendarCustomization?
    
    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.config.displayMode {
            case .month:
                TSCalendarMonthView(
                    monthData: viewModel.currentCalendarData,
                    viewModel: viewModel,
                    customization: customization
                )
            case .week:
                TSCalendarWeekView(
                    weekData: viewModel.currentWeekData,
                    viewModel: viewModel
                )
            }
        }
        .transition(.opacity)
    }
}
