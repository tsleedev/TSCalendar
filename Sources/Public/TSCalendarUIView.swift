//
//  TSCalendarUIView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 1/13/25.
//

import SwiftUI
import Combine

public class TSCalendarUIView: UIView {
    private let hostingController: UIHostingController<AnyView>
    private let minimumDate: Date?
    private let maximumDate: Date?
    private var config: TSCalendarConfig
    private let appearance: TSCalendarAppearance
    private let delegate: TSCalendarDelegate?
    private let dataSource: TSCalendarDataSource?
    private var heightConstraint: NSLayoutConstraint?
    private var configCancellables = Set<AnyCancellable>()
    private var heightCancellables = Set<AnyCancellable>()
    private var viewModel: TSCalendarViewModel
    
    public init(
        initialDate: Date = .now,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        config: TSCalendarConfig = .init(),
        appearance: TSCalendarAppearance = TSCalendarAppearance(type: .app),
        delegate: TSCalendarDelegate? = nil,
        dataSource: TSCalendarDataSource? = nil
    ) {
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.config = config
        self.appearance = appearance
        self.delegate = delegate
        self.dataSource = dataSource
        
        self.viewModel = TSCalendarViewModel(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate,
            config: config,
            delegate: delegate,
            dataSource: dataSource,
            disableSwiftUIAnimation: true
        )
        let calendarView = TSCalendarView(
            viewModel: viewModel,
            customization: nil
        )
            .environment(\.calendarAppearance, appearance)
        
        self.hostingController = UIHostingController(rootView: AnyView(calendarView))
        super.init(frame: .zero)
        bind()
        bindCalendarHeight()
        
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHostingController() {
        if let parentViewController = findViewController() {
            parentViewController.addChild(hostingController)
            hostingController.didMove(toParent: parentViewController)
        }
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        hostingController.view.backgroundColor = .clear
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    private func bind() {
        // heightStyle를 제외한 프로퍼티들 변경 감지 (자연스러운 애니메이션을 위해 heightStyle 수동으로 업데이트 필요)
        config.calendarSettingsDidChange
            .sink { [weak self] _ in
                guard let self else { return }
                reloadCalendar()
            }
            .store(in: &configCancellables)
    }
    
    private func bindCalendarHeight() {
        heightConstraint?.isActive = false
        heightCancellables = Set<AnyCancellable>()
        guard viewModel.config.heightStyle.isFixed else { return }
        
        viewModel.$currentHeight
            .compactMap { $0 }
            .sink { [weak self] height in
                guard let self else { return }
                UIView.animate(withDuration: 1) {
                    self.heightConstraint?.isActive = false
                    let headerHeight: CGFloat
                    if self.viewModel.config.showHeader {
                        headerHeight = (self.appearance.monthHeaderContentStyle.height ?? 40) + (self.appearance.weekdayHeaderContentStyle.height ?? 30)
                    } else {
                        headerHeight = self.appearance.weekdayHeaderContentStyle.height ?? 30
                    }
                    self.heightConstraint = self.hostingController.view.heightAnchor.constraint(equalToConstant: height + headerHeight)
                    self.heightConstraint?.isActive = true
                    self.setNeedsLayout()
                }
            }
            .store(in: &heightCancellables)
    }
    
    public func reloadCalendar() {
        let initialDate = viewModel.currentDisplayedDate
        let selectedDate = viewModel.selectedDate
        viewModel = TSCalendarViewModel(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate,
            config: config,
            delegate: delegate,
            dataSource: dataSource,
            disableSwiftUIAnimation: true
        )
        bindCalendarHeight()
        
        let calendarView = TSCalendarView(
            viewModel: viewModel,
            customization: nil
        )
            .environment(\.calendarAppearance, appearance)
        hostingController.rootView = AnyView(calendarView)
    }
    
    public func selectDate(_ date: Date) {
        viewModel.selectDate(date)
    }
}

// MARK: - Public Navigation Methods
extension TSCalendarUIView {
    /// 다음 월 또는 주로 이동합니다.
    ///
    /// `config.displayMode`에 따라 다음 월(.month) 또는 다음 주(.week)로 이동합니다.
    ///
    /// - Note: `calendar(pageDidChange:)` delegate 메서드가 호출되지만,
    ///   `calendar(didSelect:)`는 호출되지 않습니다. 이는 이동(navigation)이지 선택(selection)이 아니기 때문입니다.
    public func moveToNext() {
        viewModel.moveDate(by: 1)
    }

    /// 이전 월 또는 주로 이동합니다.
    ///
    /// `config.displayMode`에 따라 이전 월(.month) 또는 이전 주(.week)로 이동합니다.
    ///
    /// - Note: `calendar(pageDidChange:)` delegate 메서드가 호출되지만,
    ///   `calendar(didSelect:)`는 호출되지 않습니다. 이는 이동(navigation)이지 선택(selection)이 아니기 때문입니다.
    public func moveToPrevious() {
        viewModel.moveDate(by: -1)
    }

    /// 지정된 값만큼 월 또는 주를 이동합니다.
    ///
    /// `config.displayMode`에 따라 월(.month) 또는 주(.week) 단위로 이동합니다.
    ///
    /// - Parameter value: 이동할 개수. 양수는 미래 방향, 음수는 과거 방향으로 이동합니다.
    ///
    /// - Note: `calendar(pageDidChange:)` delegate 메서드가 호출되지만,
    ///   `calendar(didSelect:)`는 호출되지 않습니다. 이는 이동(navigation)이지 선택(selection)이 아니기 때문입니다.
    ///
    /// 예시:
    /// ```swift
    /// calendarView.move(by: 2)   // 2개월 또는 2주 앞으로
    /// calendarView.move(by: -3)  // 3개월 또는 3주 뒤로
    /// ```
    public func move(by value: Int) {
        viewModel.moveDate(by: value)
    }
}
