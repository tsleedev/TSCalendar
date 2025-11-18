//
//  CalendarProtocols.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

/// 달력에 표시할 이벤트 데이터를 제공하는 프로토콜
///
/// TSCalendar는 이벤트를 표시하기 위해 이 프로토콜을 사용합니다.
/// 두 메서드 중 하나 또는 둘 다 구현할 수 있습니다.
///
/// - Note: 범위 기반 메서드(`calendar(startDate:endDate:)`)가 성능상 더 효율적이므로 권장됩니다.
///
/// ## 사용 예제
/// ```swift
/// class MyDataSource: TSCalendarDataSource {
///     func calendar(startDate: Date, endDate: Date) -> [TSCalendarEvent] {
///         // startDate부터 endDate까지의 이벤트 반환
///         return events.filter { $0.startDate >= startDate && $0.startDate <= endDate }
///     }
/// }
/// ```
public protocol TSCalendarDataSource: AnyObject {
    /// 특정 날짜의 이벤트를 반환합니다.
    ///
    /// - Parameter date: 이벤트를 조회할 날짜
    /// - Returns: 해당 날짜의 이벤트 배열
    func calendar(date: Date) -> [TSCalendarEvent]

    /// 날짜 범위 내의 모든 이벤트를 반환합니다. (권장)
    ///
    /// 이 메서드는 주 또는 월 뷰에서 한 번에 여러 날짜의 이벤트를 조회할 때 사용되므로
    /// 단일 날짜 메서드보다 성능이 좋습니다.
    ///
    /// - Parameters:
    ///   - startDate: 조회 시작 날짜 (포함)
    ///   - endDate: 조회 종료 날짜 (포함)
    /// - Returns: 날짜 범위 내의 이벤트 배열
    func calendar(startDate: Date, endDate: Date) -> [TSCalendarEvent]
}

extension TSCalendarDataSource {
    public func calendar(date: Date) -> [TSCalendarEvent] { [] }
    public func calendar(startDate: Date, endDate: Date) -> [TSCalendarEvent] { [] }
}

/// 달력의 주요 이벤트(페이지 변경, 날짜 선택)를 수신하는 프로토콜
///
/// TSCalendar의 상태 변화를 추적하려면 이 프로토콜을 구현하세요.
/// 모든 메서드는 선택적이며, 필요한 것만 구현하면 됩니다.
///
/// ## 사용 예제
/// ```swift
/// class MyDelegate: TSCalendarDelegate {
///     func calendar(didSelect date: Date) {
///         print("선택된 날짜: \(date)")
///     }
///
///     func calendar(pageDidChange date: Date) {
///         print("페이지 변경됨: \(date)")
///         // 새로운 월의 이벤트 로드 등
///     }
/// }
/// ```
public protocol TSCalendarDelegate: AnyObject {
    /// 페이지가 변경되기 직전에 호출됩니다.
    ///
    /// 이 메서드는 애니메이션이 시작되기 전에 호출되므로,
    /// 다음 페이지의 데이터를 미리 로드하는 데 사용할 수 있습니다.
    ///
    /// - Parameter date: 변경될 페이지의 날짜 (월 뷰의 경우 해당 월의 날짜)
    func calendar(pageWillChange date: Date)

    /// 페이지 변경이 완료된 후 호출됩니다.
    ///
    /// 애니메이션이 완료되고 새 페이지가 표시된 후 호출됩니다.
    ///
    /// - Parameter date: 변경된 페이지의 날짜 (월 뷰의 경우 해당 월의 날짜)
    func calendar(pageDidChange date: Date)

    /// 사용자가 날짜를 선택했을 때 호출됩니다.
    ///
    /// 날짜 탭 또는 프로그래매틱하게 날짜가 선택되었을 때 호출됩니다.
    ///
    /// - Parameter date: 선택된 날짜
    func calendar(didSelect date: Date)
}

extension TSCalendarDelegate {
    public func calendar(pageWillChange date: Date) {}
    public func calendar(pageDidChange date: Date) {}
    public func calendar(didSelect date: Date) {}
}
