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
    
    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.displayMode {
            case .month:
                TSCalendarMonthView(
                    monthData: viewModel.datesData[1],
                    viewModel: viewModel
                )
            case .week:
                TSCalendarWeekView(
                    weekData: viewModel.datesData[1][0],  // 주 데이터는 datesData[1][0]
                    viewModel: viewModel
                )
            }
        }
        .transition(.opacity)
    }
}
