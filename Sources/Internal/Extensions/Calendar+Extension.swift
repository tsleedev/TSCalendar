//
//  Calendar+Extension.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/27/24.
//

import Foundation

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
    
    func endOfMonth(for date: Date) -> Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return self.date(byAdding: components, to: startOfMonth(for: date))!
    }
}
