//
//  TSCalendarEvent.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/27/24.
//

import SwiftUI

public struct TSCalendarEvent {
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let backgroundColor: Color
    public let textColor: Color
    
    public init(
        title: String,
        startDate: Date,
        endDate: Date,
        backgroundColor: Color = .blue.opacity(0.3),
        textColor: Color = .primary
    ) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
}
