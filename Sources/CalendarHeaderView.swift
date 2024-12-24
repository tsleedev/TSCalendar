//
//  CalendarHeaderView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct CalendarHeaderView: View {
    let currentMonth: Date
    let previousMonth: () -> Void
    let nextMonth: () -> Void
    let appearance = CalendarAppearance.shared
    
    var body: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(appearance.monthYearFormatter.string(from: currentMonth))
                .font(.system(size: appearance.headerFontSize))
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 10)
    }
}
