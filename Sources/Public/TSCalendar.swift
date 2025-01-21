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
    private let appearanceType: TSCalendarAppearanceType
    private let customization: TSCalendarCustomization?
    
    public init(
        initialDate: Date = .now,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Binding<Date?> = .constant(nil),
        config: TSCalendarConfig = .init(),
        customization: TSCalendarCustomization? = nil,
        appearanceType: TSCalendarAppearanceType = .app,
        delegate: TSCalendarDelegate? = nil,
        dataSource: TSCalendarDataSource? = nil
    ) {
        _viewModel = StateObject(wrappedValue: TSCalendarViewModel(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate.wrappedValue,
            config: config,
            delegate: delegate,
            dataSource: dataSource
        ))
        _selectedDate = selectedDate
        self.config = config
        self.appearanceType = appearanceType
        self.customization = customization
    }
    
    public var body: some View {
        TSCalendarView(
            viewModel: viewModel,
            customization: customization
        )
        .environment(\.calendarAppearance, TSCalendarAppearance(type: appearanceType))
        .id(config.id)
        .onChange(of: selectedDate) { newDate in
            if let date = newDate {
                viewModel.selectDate(date)
            }
        }
        .onChange(of: viewModel.selectedDate) { newDate in
            selectedDate = newDate  // ViewModel에서 선택이 변경될 때도 상태 업데이트
        }
    }
}
