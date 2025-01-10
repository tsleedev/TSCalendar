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
    
    let viewModel: TSCalendarViewModel
    
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

private extension PagingGestureHandler {
    @ViewBuilder
    func createCalendarView(for index: Int) -> some View {
        if let monthData = viewModel.datesData[safe: index] {
            switch viewModel.config.displayMode {
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

struct TSCalendarPagingView: View {
    @ObservedObject var viewModel: TSCalendarViewModel
    
    var body: some View {
        Group {
            if case .fixed = viewModel.config.heightStyle {
                fixedHeightContent
            } else {
                flexibleHeightContent
            }
        }
        .clipped()
    }
    
    private var fixedHeightContent: some View {
        Group {
            switch viewModel.config.scrollDirection {
            case .horizontal:
                FixedHeightHorizontalPagingView(viewModel: viewModel)
            case .vertical:
                FixedHeightVerticalPagingView(viewModel: viewModel)
            }
        }
    }
    
    private var flexibleHeightContent: some View {
        Group {
            switch viewModel.config.scrollDirection {
            case .horizontal:
                FlexibleHeightHorizontalPagingView(viewModel: viewModel)
            case .vertical:
                FlexibleHeightVerticalPagingView(viewModel: viewModel)
            }
        }
    }
}

private struct FixedHeightHorizontalPagingView: View {
    @StateObject private var handler: PagingGestureHandler
    
    init(viewModel: TSCalendarViewModel) {
        _handler = StateObject(wrappedValue: PagingGestureHandler(viewModel: viewModel))
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    handler.createCalendarView(for: index)
                        .frame(
                            width: geometry.size.width,
                            height: handler.viewModel.getPageHeight(at: index)
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
        .frame(height: handler.viewModel.currentHeight)
    }
}

private struct FixedHeightVerticalPagingView: View {
    @StateObject private var handler: PagingGestureHandler
    
    init(viewModel: TSCalendarViewModel) {
        _handler = StateObject(wrappedValue: PagingGestureHandler(viewModel: viewModel))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    handler.createCalendarView(for: index)
                        .frame(height: handler.viewModel.getPageHeight(at: index))
                }
            }
            .offset(y: -handler.viewModel.getPageHeight(at: 0) + handler.offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        handler.isDragging = true
                        handler.handleDragGesture(
                            value: value,
                            axis: .vertical,
                            pageSize: handler.viewModel.getPageHeight(at: 0),
                            nextPageSize: handler.viewModel.getPageHeight(at: 1)
                        )
                    }
                    .onEnded { value in
                        handler.isDragging = false
                        handler.handleDragGesture(
                            value: value,
                            axis: .vertical,
                            pageSize: handler.viewModel.getPageHeight(at: 0),
                            nextPageSize: handler.viewModel.getPageHeight(at: 1)
                        )
                    }
            )
            .onChange(of: handler.offset) { _ in handler.handleOffsetChange() }
        }
        .frame(height: handler.viewModel.currentHeight)
    }
}

private struct FlexibleHeightHorizontalPagingView: View {
    @StateObject private var handler: PagingGestureHandler
    
    init(viewModel: TSCalendarViewModel) {
        _handler = StateObject(wrappedValue: PagingGestureHandler(viewModel: viewModel))
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    handler.createCalendarView(for: index)
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
}

private struct FlexibleHeightVerticalPagingView: View {
    @StateObject private var handler: PagingGestureHandler
    
    init(viewModel: TSCalendarViewModel) {
        _handler = StateObject(wrappedValue: PagingGestureHandler(viewModel: viewModel))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    handler.createCalendarView(for: index)
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
}

#Preview {
    TSCalendarView(
        config: .init(
            heightStyle: .fixed(40),
            scrollDirection: .horizontal
        )
    )
}
