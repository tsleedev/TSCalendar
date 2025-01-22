//
//  Text+Extension.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/22/25.
//

import SwiftUI

extension Text {
    func textStyle(_ style: TSCalendarTextStyle) -> Text {
        self
            .font(style.font)
            .foregroundColor(style.color)
            .kerning(style.kerning)
            .tracking(style.tracking)
    }
}
