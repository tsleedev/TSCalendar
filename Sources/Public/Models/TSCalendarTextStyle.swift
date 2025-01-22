//
//  TSCalendarTextStyle.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/22/25.
//

import SwiftUI

public struct TSCalendarTextStyle: Sendable {
    public let font: Font
    public let color: Color
    public let kerning: CGFloat
    public let tracking: CGFloat

    public init(
        font: Font = .system(size: 14),
        color: Color = .primary,
        kerning: CGFloat = 0,
        tracking: CGFloat = 0
    ) {
        self.font = font
        self.color = color
        self.kerning = kerning
        self.tracking = tracking
    }
}
