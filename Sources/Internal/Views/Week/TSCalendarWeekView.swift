//
//  TSCalendarWeekView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct TSCalendarWeekView: View {
    @Environment(\.calendarAppearance) private var appearance
    
    let weekData: [TSCalendarDate]
    let viewModel: TSCalendarViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            // 날짜 행
            HStack(spacing: 0) {
                ForEach(weekData) { date in
                    GeometryReader { geometry in
                        VStack {
                            Text(appearance.dateFormatter.string(from: date.date))
                                .font(appearance.dayFont)
                                .foregroundColor(foregroundColor(for: date))
                                .frame(width: appearance.daySize, height: appearance.daySize)
                                .background(backgroundColor(for: date))
                                .clipShape(Circle())
                                .overlay {
                                    if date.isSelected {
                                        Circle()
                                            .strokeBorder(appearance.selectedColor, lineWidth: 1.5)
                                    }
                                }
                            Spacer()
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .contentShape(Rectangle())
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.selectDate(date.date)
                    }
                    .opacity(date.isInCurrentMonth ? 1 : 0.3)
                }
            }
            
            // 일정 행들
            GeometryReader { geometry in
                let dayWidth = geometry.size.width / CGFloat(weekData.count)
                
                if let firstDate = weekData.first?.date,
                   let lastDate = weekData.last?.date,
                   let events = viewModel.dataSource?.calendar(startDate: firstDate, endDate: lastDate),
                   !events.isEmpty {
                    TSCalendarEventsView(
                        weekData: weekData,
                        events: events,
                        dayWidth: dayWidth,
                        height: geometry.size.height - appearance.daySize
                    )
                    .offset(y: appearance.daySize)  // 날짜 영역 높이만큼 아래로
                }
            }
        }
    }
    
    private func foregroundColor(for date: TSCalendarDate) -> Color {
        let weekday = Calendar.current.component(.weekday, from: date.date)
        if weekday == 1 {
            return appearance.sundayColor
        } else if weekday == 7 {
            return appearance.saturdayColor
        }
        return appearance.weekdayColor
    }
    
    private func backgroundColor(for date: TSCalendarDate) -> Color {
        if date.isToday {
            return appearance.todayColor
        }
        return .clear
    }
}

#Preview {
    TSCalendarView(
        initialDate: Date(),
        minimumDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
        maximumDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
        selectedDate: Date(),
        scrollDirection: .vertical,
        environment: .app,
        delegate: nil,
        dataSource: nil
    )
}
