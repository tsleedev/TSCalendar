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
    private let appearanceType: TSCalendarAppearanceType
    
    public init(
        initialDate: Date = .now,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        config: TSCalendarConfig = .init(),
        appearanceType: TSCalendarAppearanceType = .app,
        delegate: TSCalendarDelegate? = nil,
        dataSource: TSCalendarDataSource? = nil
    ) {
        _viewModel = StateObject(wrappedValue: TSCalendarViewModel(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate,
            config: config,
            delegate: delegate,
            dataSource: dataSource
        ))
        self.config = config
        self.appearanceType = appearanceType
    }
    
    public var body: some View {
        TSCalendarView(viewModel: viewModel)
            .environment(\.calendarAppearance, TSCalendarAppearance(type: appearanceType))
            .id(config.id)
//            .onChange(of: config.heightStyle) { newHeightStyle in
//                viewModel.updateHeight()
//            }
    }
}
