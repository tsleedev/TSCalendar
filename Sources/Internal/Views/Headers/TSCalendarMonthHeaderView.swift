//
//  TSCalendarMonthHeaderView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct TSCalendarMonthHeaderView: View {
    @Environment(\.calendarAppearance) private var appearance
    @ObservedObject var viewModel: TSCalendarViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.willMoveDate(by: -1)
                viewModel.moveDate(by: -1)
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
            }
            .padding(.leading, 16)
            
            Spacer()
            
            Text(appearance.getHeaderTitle(
                date: viewModel.currentDisplayedDate,
                displayMode: viewModel.config.displayMode)
            )
            .textStyle(appearance.monthHeaderTextStyle)
            
            Spacer()
            
            Button(action: {
                viewModel.willMoveDate(by: 1)
                viewModel.moveDate(by: 1)
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
            }
            .padding(.trailing, 16)
        }
        .frame(height: appearance.monthHeaderHeight)
    }
}

#Preview {
    let viewModel = TSCalendarViewModel(
        config: .init(displayMode: .week)
    )
    TSCalendarView(
        viewModel: viewModel,
        customization: nil
    )
}
