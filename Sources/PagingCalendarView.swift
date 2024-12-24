//
//  PagingCalendarView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

#if canImport(UIKit) && !targetEnvironment(macCatalyst)
struct PagingCalendarView: View {
    enum ScrollDirection {
        case horizontal
        case vertical
        case both
    }
    
    @ObservedObject var viewModel: CalendarViewModel
    @State private var currentPage: Int = 1
    let scrollDirection: ScrollDirection
    
    init(viewModel: CalendarViewModel, scrollDirection: ScrollDirection = .horizontal) {
        self.viewModel = viewModel
        self.scrollDirection = scrollDirection
    }
    
    var body: some View {
        Group {
            switch scrollDirection {
            case .horizontal:
                horizontalPagingView
            case .vertical:
                verticalPagingView
            case .both:
                bothDirectionPagingView
            }
        }
    }
    
    private var horizontalPagingView: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<3, id: \.self) { index in
                CalendarMonthView(monthData: viewModel.monthsData[index],
                         viewModel: viewModel)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: currentPage) { handlePageChange($0) }
    }
    
    private var verticalPagingView: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<3, id: \.self) { index in
                CalendarMonthView(monthData: viewModel.monthsData[index],
                         viewModel: viewModel)
                    .tag(index)
                    .rotationEffect(.degrees(-90))
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
        .rotationEffect(.degrees(90), anchor: .topLeading)
        .offset(x: UIScreen.main.bounds.width)
        .onChange(of: currentPage) { handlePageChange($0) }
    }
    
    private var bothDirectionPagingView: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                TabView(selection: $currentPage) {
                    ForEach(0..<3, id: \.self) { index in
                        CalendarMonthView(monthData: viewModel.monthsData[index],
                                 viewModel: viewModel)
                            .tag(index)
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(width: geometry.size.width * 3,
                       height: geometry.size.height * 3)
            }
            .content.offset(x: -geometry.size.width * CGFloat(currentPage))
            .onChange(of: currentPage) { handlePageChange($0) }
        }
    }
    
    private func handlePageChange(_ newPage: Int) {
        if newPage == 0 || newPage == 2 {
            let direction = newPage == 0 ? -1 : 1
            
            // 애니메이션이 완료된 후에 데이터 업데이트
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.moveMonth(by: direction)
                withAnimation(.none) {
                    currentPage = 1
                }
            }
        }
    }
}
#endif
