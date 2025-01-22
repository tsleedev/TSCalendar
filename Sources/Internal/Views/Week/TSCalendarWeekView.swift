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
    
    private func dateOpacity(for date: TSCalendarDate) -> Double {
        switch viewModel.config.displayMode {
        case .month:
            return viewModel.config.monthStyle == .dynamic && !date.isInCurrentMonth ? 0 : (date.isInCurrentMonth ? 1 : appearance.otherMonthDateOpacity)
        case .week:
            return 1
        }
    }
    
    private var visibleDates: [TSCalendarDate] {
        weekData.filter { date in
            switch viewModel.config.displayMode {
            case .month:
                return viewModel.config.monthStyle == .dynamic ? date.isInCurrentMonth : true
            case .week:
                return true
            }
        }
    }
    
    private var visibleStartIndex: Int {
        if viewModel.config.monthStyle == .dynamic {
            return weekData.firstIndex { $0.date == visibleDates.first?.date } ?? 0
        } else {
            return 0
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // 날짜 행
            HStack(spacing: 0) {
                // 주차 표시 추가
                if viewModel.config.showWeekNumber, let date = weekData.first?.date {
                    VStack {
                        Text("\(viewModel.weekNumberOfYear(for: date))")
                            .textStyle(appearance.weekNumberTextStyle)
                            .frame(
                                width: appearance.weekNumberWidth,
                                height: appearance.daySize
                            )
                        Spacer()
                    }
                }
                
                ForEach(weekData) { date in
                    GeometryReader { geometry in
                        VStack {
                            Text(appearance.dateFormatter.string(from: date.date))
                                .textStyle(appearance.dayTextStyle)
                                .foregroundColor(foregroundColor(for: date))
                                .frame(
                                    width: appearance.daySize,
                                    height: appearance.daySize
                                )
                                .background(backgroundColor(for: date))
                                .clipShape(Circle())
                                .overlay {
                                    if date.isSelected {
                                        Circle()
                                            .strokeBorder(
                                                appearance.selectedColor,
                                                lineWidth: 1
                                            )
                                    }
                                }
                            Spacer()
                        }
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .contentShape(Rectangle())
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.selectDate(date.date)
                    }
                    .opacity(dateOpacity(for: date))
                }
            }
            
            // 일정 행들
            GeometryReader { geometry in
                let weekNumberWidth = viewModel.config.showWeekNumber ? appearance.weekNumberWidth : 0
                let dayWidth = geometry.size.width / 7
                let offsetY = appearance.daySize + 2
                
                if let firstDate = visibleDates.first?.date,
                   let lastDate = visibleDates.last?.date,
                   let events = viewModel.dataSource?.calendar(startDate: firstDate, endDate: lastDate),
                   !events.isEmpty {
                    TSCalendarEventsView(
                        weekData: visibleDates,  // 보이는 날짜만 전달
                        events: events,
                        dayWidth: dayWidth,
                        height: geometry.size.height - offsetY
                    )
                    .offset(
                        x: (CGFloat(visibleStartIndex) * dayWidth) + weekNumberWidth,
                        y: offsetY
                    )
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
    let viewModel = TSCalendarViewModel(
        initialDate: Date(),
        minimumDate: Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .now,
        maximumDate: Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now,
        selectedDate: .now,
        config: .init(
            scrollDirection: .vertical,
            showWeekNumber: true
        )
    )
    TSCalendarView(
        viewModel: viewModel,
        customization: nil
    )
}
