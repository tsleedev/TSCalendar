//
//  TSCalendarEventView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/27/24.
//

import SwiftUI

struct TSCalendarEventView: View {
    @Environment(\.calendarAppearance) private var appearance
    
    let event: TSCalendarEvent
    let width: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    
    private let margin: CGFloat = 2
    
    var body: some View {
        Text(event.title)
            .textStyle(
                TSCalendarContentStyle(
                    font: appearance.eventContentStyle.font,
                    color: event.textColor,
                    kerning: appearance.eventContentStyle.kerning,
                    tracking: appearance.eventContentStyle.tracking
                )
            )
            .lineLimit(1)
            .padding(.horizontal, 2)
            .fixedSize(horizontal: true, vertical: false)
            .frame(width: width - margin, alignment: .leading)
            .background(event.backgroundColor)
            .cornerRadius(4)
            .offset(x: offsetX, y: offsetY)
    }
}
