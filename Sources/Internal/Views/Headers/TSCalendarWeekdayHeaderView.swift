//
//  TSCalendarWeekdayHeaderView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct TSCalendarWeekdayHeaderView: View {
    @Environment(\.calendarAppearance) private var appearance
    let startWeekDay: TSCalendarStartWeekDay
    
    var body: some View {
        HStack(spacing: 0) {
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
        let offset = startWeekDay.rawValue
        return Array(symbols[offset...] + symbols[..<offset])
    }
}
