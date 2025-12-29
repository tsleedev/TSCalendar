//
//  TSCalendarWeekdayHeaderView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct TSCalendarWeekdayHeaderView: View {
    @Environment(\.calendarAppearance) private var appearance
    let viewModel: TSCalendarViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            if viewModel.config.showWeekNumber {
                Text("W")
                    .textStyle(appearance.weekdayHeaderContentStyle)
                    .foregroundColor(appearance.weekdayHeaderContentStyle.color)
                    .frame(width: appearance.weekNumberContentStyle.width)
            }

            ForEach(Array(getWeekdaySymbols().enumerated()), id: \.offset) { index, symbol in
                Text(symbol)
                    .textStyle(appearance.weekdayHeaderContentStyle)
                    .foregroundColor(appearance.weekdayHeaderContentStyle.color)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: appearance.weekdayHeaderContentStyle.rowHeight)
        .padding(.bottom, appearance.weekdayHeaderContentStyle.spacing)
    }
    
    private func getWeekdaySymbols() -> [String] {
        let symbols = appearance.getWeekdaySymbols(type: viewModel.config.weekdaySymbolType)
        let offset = viewModel.config.startWeekDay.rawValue
        return Array(symbols[offset...] + symbols[..<offset])
    }
}
