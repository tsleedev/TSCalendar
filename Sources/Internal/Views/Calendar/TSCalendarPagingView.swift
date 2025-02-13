//
//  TSCalendarPagingView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

private enum TransitionState {
    case next
    case previous
    
    var direction: Int {
        switch self {
        case .next: return 1
        case .previous: return -1
        }
    }
}

@MainActor
private class PagingGestureHandler: ObservableObject {
    @Published var offset: CGFloat = 0
    @Published var isDragging = false
    @Published var transitionState: TransitionState?
    
    @ObservedObject private var viewModel: TSCalendarViewModel
    
    private let transitionAnimation: Animation = .easeOut(duration: 0.3)
    private let transitionDelay: TimeInterval = 0.3
    private let dragThreshold: CGFloat = 50
    
    init(viewModel: TSCalendarViewModel) {
        self.viewModel = viewModel
    }
    
    func handleDragGesture(
        value: DragGesture.Value,
        axis: Axis,
        pageSize: CGFloat,
        nextPageSize: CGFloat? = nil
    ) {
        if isDragging {
            offset = axis == .horizontal ? value.translation.width : value.translation.height
            return
        }
        
        let translation = axis == .horizontal ? value.translation.width : value.translation.height
        
        if translation > dragThreshold {
            transitionState = .previous
            viewModel.willMoveDate(by: -1)
            withAnimation(transitionAnimation) {
                offset = pageSize
            }
        } else if translation < -dragThreshold {
            transitionState = .next
            viewModel.willMoveDate(by: 1)
            withAnimation(transitionAnimation) {
                offset = -(nextPageSize ?? pageSize)
            }
        } else {
            transitionState = nil
            withAnimation(transitionAnimation) {
                offset = 0
            }
        }
    }
    
    func handleOffsetChange() {
        guard let state = transitionState,
              !isDragging else { return }
        transitionState = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDelay) {
            self.viewModel.moveDate(by: state.direction)
            self.offset = 0
        }
    }
}

struct TSCalendarPagingView: View {
    @ObservedObject var viewModel: TSCalendarViewModel
    let customization: TSCalendarCustomization?
    
    var body: some View {
        Group {
            if viewModel.config.heightStyle.isFlexible {
                flexibleHeightContent
            } else {
                fixedHeightContent
            }
        }
        .contentShape(Rectangle())
        .clipped()
    }
    
    private var fixedHeightContent: some View {
        Group {
            switch viewModel.config.scrollDirection {
            case .horizontal:
                FixedHeightHorizontalPagingView(
                    viewModel: viewModel,
                    customization: customization
                )
            case .vertical:
                FixedHeightVerticalPagingView(
                    viewModel: viewModel,
                    customization: customization
                )
            }
        }
    }
    
    private var flexibleHeightContent: some View {
        Group {
            switch viewModel.config.scrollDirection {
            case .horizontal:
                FlexibleHeightHorizontalPagingView(
                    viewModel: viewModel,
                    customization: customization
                )
            case .vertical:
                FlexibleHeightVerticalPagingView(
                    viewModel: viewModel,
                    customization: customization
                )
            }
        }
    }
}

private struct FixedHeightHorizontalPagingView: View {
    @StateObject private var handler: PagingGestureHandler
    @ObservedObject private var viewModel: TSCalendarViewModel
    private let customization: TSCalendarCustomization?
    
    init(viewModel: TSCalendarViewModel, customization: TSCalendarCustomization?) {
        _handler = StateObject(wrappedValue: PagingGestureHandler(viewModel: viewModel))
        self.viewModel = viewModel
        self.customization = customization
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    calendarView(for: index)
                        .frame(
                            width: geometry.size.width,
                            height: viewModel.getPageHeight(at: index)
                        )
                }
            }
            .offset(x: -(geometry.size.width) + handler.offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        handler.isDragging = true
                        handler.handleDragGesture(
                            value: value,
                            axis: .horizontal,
                            pageSize: geometry.size.width
                        )
                    }
                    .onEnded { value in
                        handler.isDragging = false
                        handler.handleDragGesture(
                            value: value,
                            axis: .horizontal,
                            pageSize: geometry.size.width
                        )
                    }
            )
            .onChange(of: handler.offset) { _ in handler.handleOffsetChange() }
        }
        .frame(height: viewModel.currentHeight)
    }
    
    private func calendarView(for index: Int) -> some View {
        Group {
            if let monthData = viewModel.datesData[safe: index] {
                switch viewModel.config.displayMode {
                case .month:
                    TSCalendarMonthView(
                        monthData: monthData,
                        viewModel: viewModel,
                        customization: customization
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
}

private struct FixedHeightVerticalPagingView: View {
    @StateObject private var handler: PagingGestureHandler
    @ObservedObject private var viewModel: TSCalendarViewModel
    private let customization: TSCalendarCustomization?
    
    init(viewModel: TSCalendarViewModel, customization: TSCalendarCustomization?) {
        _handler = StateObject(wrappedValue: PagingGestureHandler(viewModel: viewModel))
        self.viewModel = viewModel
        self.customization = customization
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    calendarView(for: index)
                        .frame(height: viewModel.getPageHeight(at: index))
                }
            }
            .offset(y: -viewModel.getPageHeight(at: 0) + handler.offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        handler.isDragging = true
                        handler.handleDragGesture(
                            value: value,
                            axis: .vertical,
                            pageSize: viewModel.getPageHeight(at: 0),
                            nextPageSize: viewModel.getPageHeight(at: 1)
                        )
                    }
                    .onEnded { value in
                        handler.isDragging = false
                        handler.handleDragGesture(
                            value: value,
                            axis: .vertical,
                            pageSize: viewModel.getPageHeight(at: 0),
                            nextPageSize: viewModel.getPageHeight(at: 1)
                        )
                    }
            )
            .onChange(of: handler.offset) { _ in handler.handleOffsetChange() }
        }
        .frame(height: {
            return viewModel.currentHeight
        }())
    }
    
    private func calendarView(for index: Int) -> some View {
        Group {
            if let monthData = viewModel.datesData[safe: index] {
                switch viewModel.config.displayMode {
                case .month:
                    TSCalendarMonthView(
                        monthData: monthData,
                        viewModel: viewModel,
                        customization: customization
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
}

private struct FlexibleHeightHorizontalPagingView: View {
    @StateObject private var handler: PagingGestureHandler
    @ObservedObject private var viewModel: TSCalendarViewModel
    private let customization: TSCalendarCustomization?
    
    init(viewModel: TSCalendarViewModel, customization: TSCalendarCustomization?) {
        _handler = StateObject(wrappedValue: PagingGestureHandler(viewModel: viewModel))
        self.viewModel = viewModel
        self.customization = customization
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    calendarView(for: index)
                        .frame(width: geometry.size.width)
                }
            }
            .offset(x: -(geometry.size.width) + handler.offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        handler.isDragging = true
                        handler.handleDragGesture(
                            value: value,
                            axis: .horizontal,
                            pageSize: geometry.size.width
                        )
                    }
                    .onEnded { value in
                        handler.isDragging = false
                        handler.handleDragGesture(
                            value: value,
                            axis: .horizontal,
                            pageSize: geometry.size.width
                        )
                    }
            )
            .onChange(of: handler.offset) { _ in handler.handleOffsetChange() }
        }
    }
    
    private func calendarView(for index: Int) -> some View {
        Group {
            if let monthData = viewModel.datesData[safe: index] {
                switch viewModel.config.displayMode {
                case .month:
                    TSCalendarMonthView(
                        monthData: monthData,
                        viewModel: viewModel,
                        customization: customization
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
}

private struct FlexibleHeightVerticalPagingView: View {
    @StateObject private var handler: PagingGestureHandler
    @ObservedObject private var viewModel: TSCalendarViewModel
    private let customization: TSCalendarCustomization?
    
    init(viewModel: TSCalendarViewModel, customization: TSCalendarCustomization?) {
        _handler = StateObject(wrappedValue: PagingGestureHandler(viewModel: viewModel))
        self.viewModel = viewModel
        self.customization = customization
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    calendarView(for: index)
                        .frame(height: geometry.size.height)
                }
            }
            .offset(y: -(geometry.size.height) + handler.offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        handler.isDragging = true
                        handler.handleDragGesture(
                            value: value,
                            axis: .vertical,
                            pageSize: geometry.size.height
                        )
                    }
                    .onEnded { value in
                        handler.isDragging = false
                        handler.handleDragGesture(
                            value: value,
                            axis: .vertical,
                            pageSize: geometry.size.height
                        )
                    }
            )
            .onChange(of: handler.offset) { _ in handler.handleOffsetChange() }
        }
    }
    
    private func calendarView(for index: Int) -> some View {
        Group {
            if let monthData = viewModel.datesData[safe: index] {
                switch viewModel.config.displayMode {
                case .month:
                    TSCalendarMonthView(
                        monthData: monthData,
                        viewModel: viewModel,
                        customization: customization
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
}

#Preview {
    let viewModel = TSCalendarViewModel(
        config: .init(
            heightStyle: .fixed(40),
            scrollDirection: .horizontal
        )
    )
    TSCalendarView(
        viewModel: viewModel,
        customization: nil
    )
}
