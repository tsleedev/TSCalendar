//
//  TSCalendarView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct TSCalendarView: View {
    @ObservedObject var viewModel: TSCalendarViewModel
    let customization: TSCalendarCustomization?
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.config.showHeader {
                TSCalendarMonthHeaderView(
                    viewModel: viewModel
                )
                .transaction { transaction in
                    transaction.disablesAnimations = true  // 상위 애니메이션 비활성화
                }
            }
            TSCalendarWeekdayHeaderView(
                viewModel: viewModel
            )
            
            if viewModel.config.isPagingEnabled {
                TSCalendarPagingView(
                    viewModel: viewModel,
                    customization: customization
                )
            } else {
                TSCalendarStaticView(
                    viewModel: viewModel,
                    customization: customization
                )
            }
        }
    }
}

#Preview {
    let viewModel = TSCalendarViewModel()
    TSCalendarView(
        viewModel: viewModel,
        customization: nil
    )
}
