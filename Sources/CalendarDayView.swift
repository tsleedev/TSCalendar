//
//  CalendarDayView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct CalendarDayView: View {
    let calendarDate: CalendarDate
    let viewModel: CalendarViewModel
    let appearance = CalendarAppearance.shared
    
    var body: some View {
        ZStack {
            VStack(spacing: 2) {
                Text(appearance.dateFormatter.string(from: calendarDate.date))
                    .font(.system(size: appearance.dayFontSize))
                    .foregroundColor(foregroundColor)
                    .frame(width: appearance.daySize, height: appearance.daySize)
                    .background(backgroundColor)
                    .clipShape(Circle())
                
                // 커스텀 영역은 ZStack의 위에 쌓이도록
                Color.clear
                    .frame(height: 12) // 아이콘 영역 높이
                    .overlay {
                        // dataSource를 통한 커스텀 구현은 여기서
                        GeometryReader { geometry in
                            let _ = viewModel.dataSource?.calendar(dayView: self, date: calendarDate.date)
                        }
                    }
            }
        }
        .opacity(calendarDate.isInCurrentMonth ? 1 : 0.3)
    }
    
    private var foregroundColor: Color {
        if calendarDate.isToday {
            return .white
        }
        if calendarDate.isSelected {
            return .primary
        }
        let weekday = Calendar.current.component(.weekday, from: calendarDate.date)
        if weekday == 1 {
            return appearance.sundayColor
        } else if weekday == 7 {
            return appearance.saturdayColor
        }
        return appearance.weekdayColor
    }
    
    private var backgroundColor: Color {
        if calendarDate.isToday {
            return appearance.todayColor
        }
        if calendarDate.isSelected {
            return appearance.selectedColor
        }
        return .clear
    }
}
