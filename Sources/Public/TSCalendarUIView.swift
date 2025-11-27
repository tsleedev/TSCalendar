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

    /// 현재 표시되고 있는 날짜를 가져오거나 설정합니다.
    ///
    /// 이 프로퍼티를 설정하면 달력이 해당 월/주로 이동합니다.
    /// SwiftUI의 `currentDisplayedDate` Binding과 동등한 기능을 UIKit에서 제공합니다.
    ///
    /// - Note: 값을 설정하면 `calendar(pageDidChange:)` delegate가 호출될 수 있지만,
    ///   `calendar(didSelect:)`는 호출되지 않습니다.
    public var currentDisplayedDate: Date {
        get {
            return viewModel.currentDisplayedDate
        }
        set {
            viewModel.moveTo(date: newValue)
        }
    }
}

// MARK: - Public Navigation Methods
extension TSCalendarUIView {
    /// 특정 날짜로 달력을 이동합니다.
    ///
    /// - Parameters:
    ///   - date: 이동할 목표 날짜
    ///   - animated: 애니메이션 여부 (기본값: true)
    ///
    /// - Note:
    ///   - 1개월 차이일 때는 슬라이드 애니메이션, 여러 개월 차이일 때는 즉시 이동합니다.
    ///   - 이 메서드는 달력을 이동만 하며, 날짜를 선택하지 않습니다.
    ///   - 날짜 선택이 필요한 경우 `selectDate(_:)`를 별도로 호출하세요.
    ///   - `calendar(didSelect:)`는 호출되지 않습니다.
    ///
    /// 예시:
    /// ```swift
    /// // 오늘로 이동
    /// calendarView.moveTo(Date())
    ///
    /// // 3개월 후로 이동
    /// let futureDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!
    /// calendarView.moveTo(futureDate, animated: true)
    /// ```
    public func moveTo(_ date: Date, animated: Bool = true) {
        viewModel.moveTo(date: date, animated: animated)
    }

    /// 지정된 일수만큼 달력을 이동합니다.
    ///
    /// 현재 표시된 날짜에서 지정된 일수만큼 앞뒤로 이동합니다.
    /// 1일 이동 시에는 슬라이드 애니메이션이 적용되고, 여러 일 이동 시에는 즉시 이동합니다.
    ///
    /// - Parameter days: 이동할 일수. 양수는 미래 방향, 음수는 과거 방향으로 이동합니다.
    ///
    /// - Note:
    ///   - 월/주 경계를 자동으로 처리합니다.
    ///   - `calendar(pageDidChange:)` delegate 메서드가 호출되지만,
    ///     `calendar(didSelect:)`는 호출되지 않습니다. 이는 이동(navigation)이지 선택(selection)이 아니기 때문입니다.
    ///
    /// 예시:
    /// ```swift
    /// calendarView.moveDay(by: 1)    // 하루 앞으로 (애니메이션)
    /// calendarView.moveDay(by: -1)   // 하루 뒤로 (애니메이션)
    /// calendarView.moveDay(by: 7)    // 일주일 앞으로 (즉시)
    /// ```
    public func moveDay(by days: Int) {
        viewModel.moveDay(by: days)
    }
}
