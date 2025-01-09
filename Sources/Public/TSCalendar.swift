//
//  TSCalendar.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

public struct TSCalendar: View {
    private let initialDate: Date
    private let minimumDate: Date?
    private let maximumDate: Date?
    private let selectedDate: Date?
    private let config: TSCalendarConfig
    private let appearanceType: TSCalendarAppearanceType
    private let delegate: TSCalendarDelegate?
    private let dataSource: TSCalendarDataSource?
    
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
        self.initialDate = initialDate
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.selectedDate = selectedDate
        self.config = config
        self.appearanceType = appearanceType
        self.delegate = delegate
        self.dataSource = dataSource
    }
    
    public var body: some View {
        TSCalendarView(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate,
            config: config,
            delegate: delegate,
            dataSource: dataSource
        )
        .environment(\.calendarAppearance, TSCalendarAppearance(type: appearanceType))
        .id(config.id)
    }
}
