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
    @Environment(\.calendarAppearance) private var appearance

    let weekData: [TSCalendarDate]
    let events: [TSCalendarEvent]
    let dayWidth: CGFloat
    let height: CGFloat

    var body: some View {
        let totalWidth = dayWidth * CGFloat(weekData.count)
        let eventRowHeight = appearance.eventContentStyle.rowHeight ?? TSCalendarConstants.eventRowHeight
        let spacing = appearance.eventContentStyle.spacing
        let rowHeight = eventRowHeight + spacing
        let moreHeight =
            appearance.eventMoreContentStyle.rowHeight ?? TSCalendarConstants.eventMoreRowHeight
        let dateEvents = processEvents(events)
        let maxRows = Int((height - moreHeight) / rowHeight)
        if maxRows > 0 {
            ZStack(alignment: .topLeading) {
                // maxRows - 1까지만 표시
                ForEach(Array(dateEvents.prefix(maxRows).enumerated()), id: \.offset) {
                    rowIndex, rowEvents in
                    ForEach(Array(rowEvents.enumerated()), id: \.offset) { _, dateEvent in
                        let eventWidth =
                            dayWidth * CGFloat(dateEvent.endIndex - dateEvent.startIndex + 1)

                        TSCalendarEventView(
                            event: dateEvent.event,
                            width: min(eventWidth, totalWidth),
                            offsetX: dayWidth * CGFloat(dateEvent.startIndex),
                            offsetY: rowHeight * dateEvent.offsetY
                        )
                        .frame(height: rowHeight)
                    }
                }

                // 날짜별 남은 이벤트 개수 표시
                ForEach(weekData.indices, id: \.self) { index in
                    remainingCountView(
                        index: index,
                        dateEvents: dateEvents,
                        dayWidth: dayWidth,
                        moreHeight: moreHeight,
                        rowHeight: rowHeight,
                        maxRows: maxRows
                    )
                }
            }
        } else {
            EmptyView()
        }
    }

    private func processEvents(_ events: [TSCalendarEvent]) -> [[DateEvent]] {
        // 이벤트를 주차에 맞게 처리
        let calendar = Calendar.current

        let adjustedEvents = events.compactMap { event -> DateEvent? in
            let weekStartDate = weekData.first?.date
            let weekEndDate = weekData.last?.date

            // 날짜를 day 시작으로 정규화하여 타임존 이슈 방지
            guard let weekStart = weekStartDate.map({ calendar.startOfDay(for: $0) }),
                let weekEnd = weekEndDate.map({ calendar.startOfDay(for: $0) })
            else {
                return nil
            }

            let eventStart = calendar.startOfDay(for: event.startDate)
            let eventEnd = calendar.startOfDay(for: event.endDate)

            // 이벤트가 현재 주에 포함되는지 확인
            guard eventStart <= weekEnd && eventEnd >= weekStart else {
                return nil
            }

            // 시작일과 종료일을 현재 주의 범위로 조정
            let adjustedStartDate = max(eventStart, weekStart)
            let adjustedEndDate = min(eventEnd, weekEnd)

            // 조정된 날짜에 해당하는 인덱스 찾기
            guard
                let startIndex = weekData.firstIndex(where: {
                    calendar.isDate($0.date, inSameDayAs: adjustedStartDate)
                }),
                let endIndex = weekData.firstIndex(where: {
                    calendar.isDate($0.date, inSameDayAs: adjustedEndDate)
                })
            else {
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

    @ViewBuilder
    private func remainingCountView(
        index: Int,
        dateEvents: [[DateEvent]],
        dayWidth: CGFloat,
        moreHeight: CGFloat,
        rowHeight: CGFloat,
        maxRows: Int
    ) -> some View {
        let date = weekData[index].date
        let allEventsForDay = dateEvents.flatMap { $0 }.filter { event in
            let dayIndex = weekData.firstIndex {
                Calendar.current.isDate($0.date, inSameDayAs: date)
            } ?? -1
            return dayIndex >= event.startIndex && dayIndex <= event.endIndex
        }

        let visibleCount = allEventsForDay.filter { $0.offsetY < CGFloat(maxRows) }.count
        let totalCount = allEventsForDay.count
        let remainingCount = totalCount - visibleCount

        if remainingCount > 0 {
            Text("+\(remainingCount)")
                .textStyle(appearance.eventMoreContentStyle)
                .foregroundColor(appearance.eventMoreContentStyle.color)
                .frame(width: dayWidth, height: moreHeight, alignment: .center)
                .offset(
                    x: dayWidth * CGFloat(index),
                    y: rowHeight * CGFloat(maxRows)
                )
        }
    }
}
