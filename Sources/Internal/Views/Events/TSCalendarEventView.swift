//
//  TSCalendarEventView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/27/24.
//

import SwiftUI
import AppIntents

struct TSCalendarEventView: View {
    @Environment(\.calendarAppearance) private var appearance

    let event: TSCalendarEvent
    let width: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    let widgetEventIntent: ((TSCalendarEvent) -> any AppIntent)?

    private let margin: CGFloat = 2

    var body: some View {
        let eventRowHeight = appearance.eventContentStyle.rowHeight ?? TSCalendarConstants.eventRowHeight

        let content = Text(event.title)
            .textStyle(
                TSCalendarContentStyle(
                    font: appearance.eventContentStyle.font,
                    color: event.textColor,
                    kerning: appearance.eventContentStyle.kerning,
                    tracking: appearance.eventContentStyle.tracking
                )
            )
            .foregroundColor(event.textColor)
            .lineLimit(1)
            .padding(.horizontal, 2)
            .fixedSize(horizontal: true, vertical: false)
            .frame(width: width - margin, height: eventRowHeight, alignment: .leading)
            .background(event.backgroundColor)
            .cornerRadius(4)

        Group {
            if let intentBuilder = widgetEventIntent {
                Button(intent: intentBuilder(event)) {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
        .offset(x: offsetX, y: offsetY)
    }
}
