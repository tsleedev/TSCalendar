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

// MARK: - Public Navigation Methods
extension TSCalendar {
    /// 다음 월 또는 주로 이동합니다.
    ///
    /// `config.displayMode`에 따라 다음 월(.month) 또는 다음 주(.week)로 이동합니다.
    ///
    /// - Note: `calendar(pageDidChange:)` delegate 메서드가 호출되지만,
    ///   `calendar(didSelect:)`는 호출되지 않습니다. 이는 이동(navigation)이지 선택(selection)이 아니기 때문입니다.
    public func moveToNext() {
        viewModel.moveDate(by: 1)
    }

    /// 이전 월 또는 주로 이동합니다.
    ///
    /// `config.displayMode`에 따라 이전 월(.month) 또는 이전 주(.week)로 이동합니다.
    ///
    /// - Note: `calendar(pageDidChange:)` delegate 메서드가 호출되지만,
    ///   `calendar(didSelect:)`는 호출되지 않습니다. 이는 이동(navigation)이지 선택(selection)이 아니기 때문입니다.
    public func moveToPrevious() {
        viewModel.moveDate(by: -1)
    }

    /// 지정된 값만큼 월 또는 주를 이동합니다.
    ///
    /// `config.displayMode`에 따라 월(.month) 또는 주(.week) 단위로 이동합니다.
    ///
    /// - Parameter value: 이동할 개수. 양수는 미래 방향, 음수는 과거 방향으로 이동합니다.
    ///
    /// - Note: `calendar(pageDidChange:)` delegate 메서드가 호출되지만,
    ///   `calendar(didSelect:)`는 호출되지 않습니다. 이는 이동(navigation)이지 선택(selection)이 아니기 때문입니다.
    ///
    /// 예시:
    /// ```swift
    /// calendar.move(by: 2)   // 2개월 또는 2주 앞으로
    /// calendar.move(by: -3)  // 3개월 또는 3주 뒤로
    /// ```
    public func move(by value: Int) {
        viewModel.moveDate(by: value)
    }
}
