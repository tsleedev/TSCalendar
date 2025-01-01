//
//  TSCalendarPagingView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct TSCalendarPagingView: View {
    @ObservedObject var viewModel: TSCalendarViewModel
    @State private var currentPage: Int = 1
    
    var body: some View {
        Group {
            switch viewModel.scrollDirection {
            case .horizontal:
                pagingView(isVertical: false)
            case .vertical:
                pagingView(isVertical: true)
            }
        }
    }
    
    private func pagingView(isVertical: Bool) -> some View {
        GeometryReader { geometry in
            TabView(selection: $currentPage) {
                ForEach(0..<3, id: \.self) { index in
                    calendarView(for: index)
                        .tag(index)
                        .modifier(VerticalRotationModifier(
                            isVertical: isVertical,
                            geometry: geometry
                        ))
                }
            }
            .modifier(TabViewRotationModifier(
                isVertical: isVertical,
                geometry: geometry
            ))
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentPage) { handlePageChange($0) }
        }
    }
    
    private func calendarView(for index: Int) -> some View {
        Group {
            if let monthData = viewModel.datesData[safe: index] {
                switch viewModel.displayMode {
                case .month:
                    TSCalendarMonthView(
                        monthData: monthData,
                        viewModel: viewModel
                    )
                case .week:
                    TSCalendarWeekView(
                        weekData: monthData.first ?? [],
                        viewModel: viewModel
                    )
                }
            }
        }
    }
    
    private func handlePageChange(_ newPage: Int) {
        if newPage == 0 || newPage == 2 {
            let direction = newPage == 0 ? -1 : 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.moveDate(by: direction)
                withAnimation(.none) {
                    currentPage = 1
                }
            }
        }
    }
}

private struct VerticalRotationModifier: ViewModifier {
    let isVertical: Bool
    let geometry: GeometryProxy
    
    func body(content: Content) -> some View {
        if isVertical {
            content
                .rotationEffect(.degrees(-90))
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
        } else {
            content
        }
    }
}

private struct TabViewRotationModifier: ViewModifier {
    let isVertical: Bool
    let geometry: GeometryProxy
    
    func body(content: Content) -> some View {
        if isVertical {
            content
                .frame(
                    width: geometry.size.height,
                    height: geometry.size.width
                )
                .rotationEffect(.degrees(90), anchor: .topLeading)
                .offset(x: geometry.size.width)
        } else {
            content
        }
    }
}

#Preview {
    TSCalendarView(
        scrollDirection: .vertical
    )
}
