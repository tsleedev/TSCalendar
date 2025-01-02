//
//  TSCalendarEventsView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/27/24.
//

import SwiftUI

private struct DateEvent {
    let event: TSCalendarEvent
    let startIndex: Int
    let endIndex: Int
    var offsetY: CGFloat = 0
}

struct TSCalendarEventsView: View {
    let weekData: [TSCalendarDate]
    let events: [TSCalendarEvent]
    let dayWidth: CGFloat
    let height: CGFloat
    private let rowHeight: CGFloat = 18
    
    var body: some View {
        let totalWidth = dayWidth * CGFloat(weekData.count)
        let dateEvents = processEvents(events)
        let maxRows = Int(height / rowHeight)
        if maxRows > 0 {
            ZStack(alignment: .topLeading) {
                // maxRows - 1까지만 표시
                ForEach(Array(dateEvents.prefix(maxRows-1).enumerated()), id: \.offset) { rowIndex, rowEvents in
                    ForEach(Array(rowEvents.enumerated()), id: \.offset) { _, dateEvent in
                        let eventWidth = dayWidth * CGFloat(dateEvent.endIndex - dateEvent.startIndex + 1)
                        
                        TSCalendarEventView(
                            event: dateEvent.event,
                            width: min(eventWidth, totalWidth),
                            offsetX: dayWidth * CGFloat(dateEvent.startIndex),
                            offsetY: rowHeight * dateEvent.offsetY
                        )
                    }
                }
                
                // 날짜별 남은 이벤트 개수 표시
                ForEach(weekData.indices, id: \.self) { index in
                    let date = weekData[index].date
                    let allEventsForDay = dateEvents.flatMap { $0 }.filter { event in
                        let dayIndex = weekData.firstIndex { Calendar.current.isDate($0.date, inSameDayAs: date) } ?? -1
                        return dayIndex >= event.startIndex && dayIndex <= event.endIndex
                    }
                    
                    let visibleCount = allEventsForDay.filter { $0.offsetY < CGFloat(maxRows-1) }.count
                    let totalCount = allEventsForDay.count
                    let remainingCount = totalCount - visibleCount
                    
                    if remainingCount > 0 {
                        Text("+\(remainingCount)")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .frame(width: dayWidth, alignment: .center)
                            .offset(
                                x: dayWidth * CGFloat(index),
                                y: rowHeight * CGFloat(maxRows-1)
                            )
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
    
    private func processEvents(_ events: [TSCalendarEvent]) -> [[DateEvent]] {
        // 이벤트를 주차에 맞게 처리
        let adjustedEvents = events.compactMap { event -> DateEvent? in
            let weekStartDate = weekData.first?.date
            let weekEndDate = weekData.last?.date
            
            // 이벤트가 현재 주에 포함되는지 확인
            guard let weekStart = weekStartDate,
                  let weekEnd = weekEndDate,
                  event.startDate <= weekEnd && event.endDate >= weekStart else {
                return nil
            }
            
            // 시작일과 종료일을 현재 주의 범위로 조정
            let adjustedStartDate = max(event.startDate, weekStart)
            let adjustedEndDate = min(event.endDate, weekEnd)
            
            // 조정된 날짜에 해당하는 인덱스 찾기
            guard let startIndex = weekData.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: adjustedStartDate) }),
                  let endIndex = weekData.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: adjustedEndDate) }) else {
                return nil
            }
            
            return DateEvent(event: event, startIndex: startIndex, endIndex: endIndex)
        }
        
        return organizeEvents(adjustedEvents)
    }
    
    private func organizeEvents(_ events: [DateEvent]) -> [[DateEvent]] {
        var rows: [[DateEvent]] = []
        var remainingEvents = events.sorted { $0.startIndex < $1.startIndex }
        
        while !remainingEvents.isEmpty {
            var currentRow: [DateEvent] = []
            var lastEndIndex = -1
            
            remainingEvents = remainingEvents.filter { event in
                if event.startIndex > lastEndIndex {
                    currentRow.append(event)
                    lastEndIndex = event.endIndex
                    return false
                }
                return true
            }
            
            rows.append(currentRow)
        }
        
        // Y offset 설정
        for (rowIndex, row) in rows.enumerated() {
            for i in 0..<row.count {
                rows[rowIndex][i].offsetY = CGFloat(rowIndex)
            }
        }
        
        return rows
    }
}
