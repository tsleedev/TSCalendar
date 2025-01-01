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
    
    init(viewModel: TSCalendarViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            switch viewModel.scrollDirection {
            case .horizontal:
                horizontalPagingView
            case .vertical:
                verticalPagingView
            }
        }
    }
    
    private var horizontalPagingView: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<3, id: \.self) { index in
                Group {
                    switch viewModel.displayMode {
                    case .month:
                        TSCalendarMonthView(
                            monthData: viewModel.datesData[index],
                            viewModel: viewModel
                        )
                    case .week:
                        TSCalendarWeekView(
                            weekData: viewModel.datesData[index][0],
                            viewModel: viewModel
                        )
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: currentPage) { handlePageChange($0) }
    }
    
    private var verticalPagingView: some View {
        GeometryReader { geometry in
            TabView(selection: $currentPage) {
                ForEach(0..<3, id: \.self) { index in
                    Group {
                        switch viewModel.displayMode {
                        case .month:
                            TSCalendarMonthView(
                                monthData: viewModel.datesData[index],
                                viewModel: viewModel
                            )
                        case .week:
                            TSCalendarWeekView(
                                weekData: viewModel.datesData[index][0],
                                viewModel: viewModel
                            )
                        }
                    }
                    .tag(index)
                    .rotationEffect(.degrees(-90))
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                }
            }
            .frame(
                width: geometry.size.height,
                height: geometry.size.width
            )
            .tabViewStyle(.page(indexDisplayMode: .never))
            .rotationEffect(.degrees(90), anchor: .topLeading)
            .offset(x: geometry.size.width)
            .onChange(of: currentPage) { handlePageChange($0) }
        }
    }
    
    private func handlePageChange(_ newPage: Int) {
        if newPage == 0 || newPage == 2 {
            let direction = newPage == 0 ? -1 : 1
            
            // 애니메이션이 완료된 후에 데이터 업데이트
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.moveDate(by: direction)
                withAnimation(.none) {
                    currentPage = 1
                }
            }
        }
    }
}

#Preview {
    TSCalendarView(
        scrollDirection: .vertical
    )
}
