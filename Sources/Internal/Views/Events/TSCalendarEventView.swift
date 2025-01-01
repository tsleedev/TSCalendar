//
//  TSCalendarEventView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/27/24.
//

import SwiftUI

struct TSCalendarEventView: View {
    let event: TSCalendarEvent
    let width: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    
    private let margin: CGFloat = 2
    
    var body: some View {
        Text(event.title)
            .font(.system(size: 10))
            .lineLimit(1)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .frame(width: width - margin, alignment: .leading)
            .background(event.backgroundColor)
            .foregroundColor(event.textColor)
            .cornerRadius(4)
            .offset(x: offsetX, y: offsetY)
    }
}
