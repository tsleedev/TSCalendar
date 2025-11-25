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
                            .textStyle(appearance.weekNumberContentStyle)
                            .foregroundColor(appearance.weekNumberContentStyle.color)
                            .frame(
                                width: appearance.weekNumberContentStyle.width ?? TSCalendarConstants.weekNumberWidth,
                                height: appearance.dayContentStyle.height ?? TSCalendarConstants.daySize
                            )
                        Spacer()
                    }
                }
                
                ForEach(weekData) { date in
                    GeometryReader { geometry in
                        VStack(spacing: 1) {
                            Text(appearance.dateFormatter.string(from: date.date))
                                .textStyle(appearance.dayContentStyle)
                                .foregroundColor(foregroundColor(for: date))
                                .frame(
                                    width: appearance.dayContentStyle.width ?? TSCalendarConstants.daySize,
                                    height: appearance.dayContentStyle.height ?? TSCalendarConstants.daySize
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

                            // 이벤트 인디케이터 (dots/count 스타일)
                            if viewModel.config.eventDisplayStyle == .dots || viewModel.config.eventDisplayStyle == .count {
                                eventIndicator(for: date)
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
            
            // 일정 행들 (bars 스타일일 때만)
            if viewModel.config.eventDisplayStyle == .bars {
                GeometryReader { geometry in
                    let weekNumberWidth = viewModel.config.showWeekNumber ? (appearance.weekNumberContentStyle.width ?? TSCalendarConstants.weekNumberWidth) : 0
                    let dayWidth = (geometry.size.width - weekNumberWidth) / 7
                    let offsetY = (appearance.dayContentStyle.height ?? TSCalendarConstants.daySize) + 2

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
    }

    // MARK: - Event Indicator

    @ViewBuilder
    private func eventIndicator(for date: TSCalendarDate) -> some View {
        let count = eventCount(for: date.date)
        let height = appearance.eventMoreContentStyle.height ?? TSCalendarConstants.eventMoreHeight

        Group {
            if count > 0 {
                switch viewModel.config.eventDisplayStyle {
                case .dots:
                    Circle()
                        .fill(appearance.eventContentStyle.color)
                        .frame(width: 4, height: 4)
                case .count:
                    Text("+\(count)")
                        .textStyle(appearance.eventMoreContentStyle)
                        .foregroundColor(appearance.eventMoreContentStyle.color)
                default:
                    EmptyView()
                }
            } else {
                // 빈 공간 유지 (일관된 높이)
                Color.clear
            }
        }
        .frame(height: height)
    }

    private func eventCount(for date: Date) -> Int {
        guard let events = viewModel.dataSource?.calendar(date: date) else { return 0 }
        return events.count
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
