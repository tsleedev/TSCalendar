//
//  CalendarWeekdayHeaderView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct CalendarWeekdayHeaderView: View {
    let appearance = CalendarAppearance.shared
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(appearance.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: appearance.weekdayHeaderFontSize))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(appearance.weekdayHeaderColor)
            }
        }
        .frame(height: appearance.headerHeight)
    }
}
