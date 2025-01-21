//
//  CustomWeekView.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 1/21/25.
//


import SwiftUI
import TSCalendar

struct CustomWeekView: View {
    let weekData: [TSCalendarDate]
    let didSelectDate: (Date) -> Void
    let displayMode: TSCalendarDisplayMode = .month
    let monthStyle: TSCalendarMonthStyle = .dynamic
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    private let daySize: CGFloat = 25
    
    private func dateOpacity(for date: TSCalendarDate) -> Double {
        switch displayMode {
        case .month:
            return monthStyle == .dynamic && !date.isInCurrentMonth ? 0 : (date.isInCurrentMonth ? 1 : 0.3)
        case .week:
            return 1
        }
    }
    
    private var visibleDates: [TSCalendarDate] {
        weekData.filter { date in
            switch displayMode {
            case .month:
                return monthStyle == .dynamic ? date.isInCurrentMonth : true
            case .week:
                return true
            }
        }
    }
    
    private var visibleStartIndex: Int {
        if monthStyle == .dynamic {
            return weekData.firstIndex { $0.date == visibleDates.first?.date } ?? 0
        } else {
            return 0
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // 날짜 행
            HStack(spacing: 0) {
                ForEach(weekData) { date in
                    GeometryReader { geometry in
                        VStack {
                            Text(dateFormatter.string(from: date.date))
                                .font(.system(size: 14))
                                .foregroundColor(foregroundColor(for: date))
                                .frame(
                                    width: daySize,
                                    height: daySize
                                )
                                .background(backgroundColor(for: date))
                                .clipShape(Circle())
                                .overlay {
                                    if date.isSelected {
                                        Circle()
                                            .strokeBorder(
                                                .gray.opacity(0.5),
                                                lineWidth: 1.5
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
                        didSelectDate(date.date)
                    }
                    .opacity(dateOpacity(for: date))
                }
            }
        }
    }
    
    private func foregroundColor(for date: TSCalendarDate) -> Color {
        let weekday = Calendar.current.component(.weekday, from: date.date)
        if weekday == 1 {
            return .red
        } else if weekday == 7 {
            return .blue
        }
        return .primary
    }
    
    private func backgroundColor(for date: TSCalendarDate) -> Color {
        if date.isToday {
            return .gray.opacity(0.5)
        }
        return .clear
    }
}
