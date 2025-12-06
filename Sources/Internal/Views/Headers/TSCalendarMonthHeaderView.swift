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
            if viewModel.config.isPagingEnabled {
                pagingHeader
            } else {
                staticHeader
            }
        }
        .frame(height: appearance.monthHeaderContentStyle.rowHeight)
    }

    // MARK: - Paging Header (버튼이 있는 헤더)
    private var pagingHeader: some View {
        HStack {
            navigationButton(direction: -1) // 이전 버튼

            Spacer()

            Text(appearance.getHeaderTitle(
                date: viewModel.currentDisplayedDate,
                displayMode: viewModel.config.displayMode
            ))
            .textStyle(appearance.monthHeaderContentStyle)
            .foregroundColor(appearance.monthHeaderContentStyle.color)

            Spacer()

            navigationButton(direction: 1) // 다음 버튼
        }
    }

    // MARK: - Static Header (버튼이 없는 헤더)
    private var staticHeader: some View {
        HStack {
            Text(appearance.getHeaderTitle(
                date: viewModel.currentDisplayedDate,
                displayMode: viewModel.config.displayMode
            ))
            .textStyle(appearance.monthHeaderContentStyle)
            .foregroundColor(appearance.monthHeaderContentStyle.color)

            Spacer()
        }
        .padding(.horizontal, 12)
    }

    // MARK: - Navigation Button
    private func navigationButton(direction: Int) -> some View {
        Button(action: {
            viewModel.moveMonth(by: direction, animated: true)
        }) {
            Image(systemName: direction < 0 ? "chevron.left" : "chevron.right")
                .foregroundColor(.primary)
        }
        .padding(direction < 0 ? .leading : .trailing, 16)
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
