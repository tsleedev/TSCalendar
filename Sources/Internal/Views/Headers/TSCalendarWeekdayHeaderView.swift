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
                Text("W")  // 또는 빈 공간을 위해 ""
                    .font(appearance.weekdayHeaderFont)
                    .frame(width: appearance.weekNumberWidth)
                    .foregroundColor(appearance.weekdayHeaderColor)
            }
            
            ForEach(getWeekdaySymbols(), id: \.self) { symbol in
                Text(symbol)
                    .font(appearance.weekdayHeaderFont)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(appearance.weekdayHeaderColor)
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
