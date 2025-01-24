//
//  TSCalendarTextStyle.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/22/25.
//

import SwiftUI

public struct TSCalendarContentStyle: Sendable {
    public let font: Font
    public let color: Color
    public let kerning: CGFloat
    public let tracking: CGFloat
    public let width: CGFloat?  // 컨텐츠 너비 (nil일 경우 자동)
    public let height: CGFloat? // 컨텐츠 높이 (nil일 경우 자동)

    public init(
        font: Font = .system(size: 14),
        color: Color = .primary,
        kerning: CGFloat = 0,
        tracking: CGFloat = 0,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) {
        self.font = font
        self.color = color
        self.kerning = kerning
        self.tracking = tracking
        self.width = width
        self.height = height
    }
}
