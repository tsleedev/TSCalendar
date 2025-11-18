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
        guard let startDate = self.date(from: components) else {
            // Fallback: 날짜 생성 실패 시 원본 날짜의 시작 시간 반환
            return startOfDay(for: date)
        }
        return startDate
    }

    func endOfMonth(for date: Date) -> Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1

        let monthStart = startOfMonth(for: date)
        guard let endDate = self.date(byAdding: components, to: monthStart) else {
            // Fallback: 날짜 계산 실패 시 월의 시작 날짜 반환
            return monthStart
        }
        return endDate
    }
}
