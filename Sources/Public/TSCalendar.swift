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
    private var currentDisplayedDate: Binding<Date>?
    private let appearance: TSCalendarAppearance
    private let customization: TSCalendarCustomization?

    /// ViewModel에 접근하기 위한 프로퍼티
    /// - Note: 이 프로퍼티는 View가 생성된 후에만 접근해야 합니다.
    public var calendarViewModel: TSCalendarViewModel {
        viewModel
    }

    public init(
        initialDate: Date = .now,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        currentDisplayedDate: Binding<Date>? = nil,
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

        // currentDisplayedDate가 제공되면 해당 날짜를 사용, 아니면 initialDate 사용
        let displayDate = currentDisplayedDate?.wrappedValue ?? adjustedInitialDate

        _viewModel = StateObject(
            wrappedValue: TSCalendarViewModel(
                initialDate: displayDate,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                selectedDate: selectedDate.wrappedValue,
                config: config,
                delegate: delegate,
                dataSource: dataSource
            ))
        _selectedDate = selectedDate
        self.currentDisplayedDate = currentDisplayedDate
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
        .onChange(of: currentDisplayedDate?.wrappedValue) { newDate in
            // currentDisplayedDate binding이 변경되면 해당 월/주로 이동
            if let date = newDate,
                !Calendar.current.isDate(date, inSameDayAs: viewModel.currentDisplayedDate)
            {
                viewModel.moveTo(date: date)
            }
        }
        .onChange(of: viewModel.currentDisplayedDate) { newDate in
            // ViewModel의 currentDisplayedDate가 변경되면 binding 업데이트
            if let binding = currentDisplayedDate,
                !Calendar.current.isDate(newDate, inSameDayAs: binding.wrappedValue)
            {
                currentDisplayedDate?.wrappedValue = newDate
            }
        }
    }
}

// MARK: - Public Navigation Methods
extension TSCalendar {
    /// 특정 날짜로 달력을 이동합니다.
    ///
    /// - Parameters:
    ///   - date: 이동할 목표 날짜
    ///   - animated: 애니메이션 여부 (기본값: true)
    ///
    /// - Note:
    ///   - 1개월 차이일 때는 슬라이드 애니메이션, 여러 개월 차이일 때는 즉시 이동합니다.
    ///   - 이 메서드는 달력을 이동만 하며, 날짜를 선택하지 않습니다.
    ///   - 날짜 선택이 필요한 경우 `selectDate(_:)`를 별도로 호출하세요.
    ///   - `calendar(didSelect:)`는 호출되지 않습니다. 이는 이동(navigation)이지 선택(selection)이 아니기 때문입니다.
    ///
    /// 예시:
    /// ```swift
    /// // 오늘로 이동
    /// calendar.moveTo(Date())
    ///
    /// // 3개월 후로 이동
    /// let futureDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!
    /// calendar.moveTo(futureDate, animated: true)
    ///
    /// // 특정 날짜로 즉시 이동 (애니메이션 없이)
    /// calendar.moveTo(someDate, animated: false)
    /// ```
    public func moveTo(_ date: Date, animated: Bool = true) {
        viewModel.moveTo(date: date, animated: animated)
    }

    /// 지정된 일수만큼 달력을 이동합니다.
    ///
    /// 현재 표시된 날짜에서 지정된 일수만큼 앞뒤로 이동합니다.
    ///
    /// - Parameters:
    ///   - days: 이동할 일수. 양수는 미래 방향, 음수는 과거 방향으로 이동합니다.
    ///   - animated: 애니메이션 여부 (기본값: true)
    ///
    /// - Note:
    ///   - 월/주 경계를 자동으로 처리합니다.
    ///   - `calendar(pageDidChange:)` delegate 메서드가 호출되지만,
    ///     `calendar(didSelect:)`는 호출되지 않습니다. 이는 이동(navigation)이지 선택(selection)이 아니기 때문입니다.
    ///
    /// 예시:
    /// ```swift
    /// calendar.moveDay(by: 1)                    // 하루 앞으로 (애니메이션)
    /// calendar.moveDay(by: -1, animated: false)  // 하루 뒤로 (즉시)
    /// calendar.moveDay(by: 7)                    // 일주일 앞으로 (애니메이션)
    /// ```
    public func moveDay(by days: Int, animated: Bool = true) {
        viewModel.moveDay(by: days, animated: animated)
    }

    /// 지정된 월수만큼 달력을 이동합니다.
    ///
    /// 선택된 날짜에서 지정된 월수만큼 앞뒤로 이동합니다.
    ///
    /// - Parameters:
    ///   - months: 이동할 월수. 양수는 미래 방향, 음수는 과거 방향으로 이동합니다.
    ///   - animated: 애니메이션 여부 (기본값: true)
    ///
    /// - Note:
    ///   - `autoSelect` 설정이 켜져 있으면:
    ///     - 현재 달로 이동 시: 오늘 날짜 선택
    ///     - 다른 달로 이동 시: 해당 월의 1일 선택
    ///   - `autoSelect` 설정이 꺼져 있으면 달력만 이동하고 선택은 변경하지 않습니다.
    ///   - `calendar(pageDidChange:)` delegate 메서드가 호출되지만,
    ///     `calendar(didSelect:)`는 호출되지 않습니다.
    ///
    /// 예시:
    /// ```swift
    /// calendar.moveMonth(by: 1)                    // 다음 달로 (애니메이션)
    /// calendar.moveMonth(by: -1, animated: false)  // 이전 달로 (즉시)
    /// calendar.moveMonth(by: 3)                    // 3개월 앞으로 (애니메이션)
    /// ```
    public func moveMonth(by months: Int, animated: Bool = true) {
        viewModel.moveMonth(by: months, animated: animated)
    }
}
