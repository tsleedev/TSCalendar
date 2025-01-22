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
                    .textStyle(appearance.weekdayHeaderTextStyle)
                    .frame(width: appearance.weekNumberWidth)
            }
            
            ForEach(getWeekdaySymbols(), id: \.self) { symbol in
                Text(symbol)
                    .textStyle(appearance.weekdayHeaderTextStyle)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: appearance.weekdayHeaderHeight)
    }
    
    private func getWeekdaySymbols() -> [String] {
        let symbols = appearance.weekdaySymbols
        let offset = viewModel.config.startWeekDay.rawValue
        return Array(symbols[offset...] + symbols[..<offset])
    }
}
