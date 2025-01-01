//
//  TSCalendarModels.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import Foundation

// MARK: - Models
struct TSCalendarDate: Identifiable {
    let id = UUID()
    let date: Date
    var isSelected: Bool = false
    var isToday: Bool = false
    var isInCurrentMonth: Bool = true
}
