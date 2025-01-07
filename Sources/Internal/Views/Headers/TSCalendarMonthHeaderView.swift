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
    let environment: TSCalendarEnvironment
    
    var body: some View {
        HStack {
            if environment.showNavigationButtons {
                Button(action: { viewModel.moveDate(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                .padding(.leading, 16)
                
                Spacer()
                
                Text(appearance.getHeaderTitle(
                    date: viewModel.currentDisplayedDate,
                    displayMode: viewModel.config.displayMode)
                )
                .font(appearance.monthHeaderFont)
                
                Spacer()
                
                Button(action: { viewModel.moveDate(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
                .padding(.trailing, 16)
            } else {
                Text(appearance.getHeaderTitle(
                    date: viewModel.currentDisplayedDate,
                    displayMode: viewModel.config.displayMode)
                )
                .font(appearance.monthHeaderFont)
                .padding(.leading, 16)
                Spacer()
            }
        }
        .frame(height: appearance.monthHeaderHeight)
    }
}

#Preview {
    TSCalendarView(
        config: .init(displayMode: .week),
        environment: .widget
    )
}
