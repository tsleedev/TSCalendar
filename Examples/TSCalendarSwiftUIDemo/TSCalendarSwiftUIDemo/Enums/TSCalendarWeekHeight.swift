//
//  TSCalendarWeekHeight.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 1/7/25.
//

import Foundation

public enum WeekHeight: CaseIterable {
    case flexible
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .flexible: return 0  // 유동적 높이
        case .small: return 40
        case .medium: return 60
        case .large: return 80
        }
    }
    
    var description: String {
        switch self {
        case .flexible: return "Flexible"
        case .small: return "Small (40pt)"
        case .medium: return "Medium (60pt)"
        case .large: return "Large (80pt)"
        }
    }
}
