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

    // 레이스 컨디션 방지를 위한 DispatchWorkItem
    private var pendingWorkItem: DispatchWorkItem?

    // 빠른 스와이프 시 이동 횟수 누적 (다음: +1, 이전: -1)
    private var pendingMoveCount: Int = 0

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
            pendingMoveCount -= 1
            viewModel.willMoveDate(by: -1)
            withAnimation(transitionAnimation) {
                offset = pageSize
            }
        } else if translation < -dragThreshold {
            transitionState = .next
            pendingMoveCount += 1
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
        guard transitionState != nil, !isDragging else {
            return
        }

        // Don't clear transitionState here - keep it to block rapid clicks until animation completes

        // 이전 작업이 있다면 취소
        pendingWorkItem?.cancel()

        // 새로운 작업 생성
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            // 누적된 이동 횟수를 로컬에 저장 후 리셋
            let moveBy = self.pendingMoveCount
            self.pendingMoveCount = 0

            // 누적된 횟수가 0이 아닐 때만 이동 (앞뒤로 스와이프해서 상쇄된 경우 제외)
            if moveBy != 0 {
                self.viewModel.moveDate(by: moveBy)
            }

            // Clear transitionState BEFORE resetting offset to prevent triggering handleOffsetChange again
            self.transitionState = nil
            self.offset = 0
        }

        pendingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDelay, execute: workItem)
    }

    /// 외부 버튼 클릭 시 애니메이션 트리거 처리
    func handleExternalTrigger(
        direction: Int,
        pageSize: CGFloat,
        nextPageSize: CGFloat? = nil
    ) {
        // pendingAnimatedMove 초기화 - guard 이전에 수행하여 차단된 경우에도 초기화 보장
        viewModel.pendingAnimatedMove = nil

        // 이미 애니메이션 중이면 무시
        guard transitionState == nil else {
            return
        }

        // 방향에 따른 애니메이션 설정
        if direction > 0 {
            transitionState = .next
            pendingMoveCount += 1
            viewModel.willMoveDate(by: 1)
            withAnimation(transitionAnimation) {
                offset = -(nextPageSize ?? pageSize)
            }
        } else if direction < 0 {
            transitionState = .previous
            pendingMoveCount -= 1
            viewModel.willMoveDate(by: -1)
            withAnimation(transitionAnimation) {
                offset = pageSize
            }
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
            .onChange(of: handler.offset) { _ in
                handler.handleOffsetChange()
            }
            .onChange(of: viewModel.pendingAnimatedMove) { direction in
                if let direction = direction {
                    handler.handleExternalTrigger(
                        direction: direction,
                        pageSize: geometry.size.width
                    )
                }
            }
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
            .onChange(of: handler.offset) { _ in
                handler.handleOffsetChange()
            }
            .onChange(of: viewModel.pendingAnimatedMove) { direction in
                if let direction = direction {
                    handler.handleExternalTrigger(
                        direction: direction,
                        pageSize: viewModel.getPageHeight(at: 0),
                        nextPageSize: viewModel.getPageHeight(at: 1)
                    )
                }
            }
        }
        .frame(
            height: {
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
            .onChange(of: handler.offset) { _ in
                handler.handleOffsetChange()
            }
            .onChange(of: viewModel.pendingAnimatedMove) { direction in
                if let direction = direction {
                    handler.handleExternalTrigger(
                        direction: direction,
                        pageSize: geometry.size.width
                    )
                }
            }
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
            .onChange(of: handler.offset) { _ in
                handler.handleOffsetChange()
            }
            .onChange(of: viewModel.pendingAnimatedMove) { direction in
                if let direction = direction {
                    handler.handleExternalTrigger(
                        direction: direction,
                        pageSize: geometry.size.height
                    )
                }
            }
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
