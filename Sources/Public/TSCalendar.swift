//
//  TSCalendar.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

public struct TSCalendar: View {
    @StateObject var viewModel: TSCalendarViewModel
    @ObservedObject var config: TSCalendarConfig
    @Binding var selectedDate: Date?
    private let appearance: TSCalendarAppearance
    private let customization: TSCalendarCustomization?

    public init(
        initialDate: Date = .now,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Binding<Date?> = .constant(nil),
        config: TSCalendarConfig = .init(),
        customization: TSCalendarCustomization? = nil,
        appearance: TSCalendarAppearance = TSCalendarAppearance(type: .app),
        delegate: TSCalendarDelegate? = nil,
        dataSource: TSCalendarDataSource? = nil
    ) {
        // 날짜 범위 검증
        if let minDate = minimumDate, let maxDate = maximumDate {
            assert(
                minDate <= maxDate,
                "TSCalendar: minimumDate는 maximumDate보다 이전이거나 같아야 합니다. minimumDate: \(minDate), maximumDate: \(maxDate)"
            )
        }

        // initialDate가 범위 내에 있는지 확인하고 필요시 조정
        var adjustedInitialDate = initialDate
        if let minDate = minimumDate, initialDate < minDate {
            adjustedInitialDate = minDate
        } else if let maxDate = maximumDate, initialDate > maxDate {
            adjustedInitialDate = maxDate
        }

        _viewModel = StateObject(
            wrappedValue: TSCalendarViewModel(
                initialDate: adjustedInitialDate,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                selectedDate: selectedDate.wrappedValue,
                config: config,
                delegate: delegate,
                dataSource: dataSource
            ))
        _selectedDate = selectedDate
        self.config = config
        self.appearance = appearance
        self.customization = customization
    }

    public var body: some View {
        TSCalendarView(
            viewModel: viewModel,
            customization: customization
        )
        .environment(\.calendarAppearance, appearance)
        .id(config.id)
        .onChange(of: selectedDate) { newDate in
            // 중복 업데이트 방지: 이미 같은 값이면 selectDate 호출하지 않음
            if let date = newDate,
                !Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate ?? .distantPast)
            {
                viewModel.selectDate(date)
            }
        }
        .onChange(of: viewModel.selectedDate) { newDate in
            // ViewModel에서 선택이 변경될 때도 상태 업데이트
            // 중복 업데이트 방지: 이미 같은 값이면 업데이트하지 않음
            if let vmDate = newDate, let bindingDate = selectedDate {
                if !Calendar.current.isDate(vmDate, inSameDayAs: bindingDate) {
                    selectedDate = newDate
                }
            } else if newDate != selectedDate {
                selectedDate = newDate
            }
        }
    }
}
