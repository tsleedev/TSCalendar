//
//  Collection+Extension.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/1/25.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}
