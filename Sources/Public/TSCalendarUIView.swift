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
    private let initialDate: Date
    private let minimumDate: Date?
    private let maximumDate: Date?
    private let selectedDate: Date?
    private var config: TSCalendarConfig
    private let appearance: TSCalendarAppearance
    private let delegate: TSCalendarDelegate?
    private let dataSource: TSCalendarDataSource?
    private var heightConstraint: NSLayoutConstraint?
    private var cancellable = Set<AnyCancellable>()
    
    public init(
        initialDate: Date = .now,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        config: TSCalendarConfig = .init(),
        appearanceType: TSCalendarAppearanceType = .app,
        delegate: TSCalendarDelegate? = nil,
        dataSource: TSCalendarDataSource? = nil
    ) {
        self.initialDate = initialDate
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.selectedDate = selectedDate
        self.config = config
        self.appearance = TSCalendarAppearance(type: appearanceType)
        self.delegate = delegate
        self.dataSource = dataSource
        
        let viewModel = TSCalendarViewModel(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate,
            config: config,
            delegate: delegate,
            dataSource: dataSource,
            disableSwiftUIAnimation: true
        )
        let calendarView = TSCalendarView(viewModel: viewModel)
            .environment(\.calendarAppearance, appearance)
            .id(config.id)
        
        self.hostingController = UIHostingController(rootView: AnyView(calendarView))
        super.init(frame: .zero)
        bindCalendarHeight(viewModel: viewModel)
        
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
        config.displayMode
    }
    
    private func bindCalendarHeight(viewModel: TSCalendarViewModel) {
        heightConstraint?.isActive = false
        cancellable = Set<AnyCancellable>()
        guard viewModel.config.heightStyle.isFixed else { return }
        
        viewModel.$currentHeight
            .compactMap { $0 }
            .sink { [weak self] height in
                guard let self else { return }
                UIView.animate(withDuration: 1) {
                    self.heightConstraint?.isActive = false
                    let headerHeight: CGFloat
                    if viewModel.config.showHeader {
                        headerHeight = self.appearance.monthHeaderHeight + self.appearance.weekdayHeaderHeight
                    } else {
                        headerHeight = self.appearance.weekdayHeaderHeight
                    }
                    self.heightConstraint = self.hostingController.view.heightAnchor.constraint(equalToConstant: height + headerHeight)
                    self.heightConstraint?.isActive = true
                    self.setNeedsLayout()
                }
            }
            .store(in: &cancellable)
    }
    
    public func updateConfig(_ newConfig: TSCalendarConfig) {
        self.config = newConfig
        let viewModel = TSCalendarViewModel(
            initialDate: initialDate,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            selectedDate: selectedDate,
            config: config,
            delegate: delegate,
            dataSource: dataSource,
            disableSwiftUIAnimation: true
        )
        bindCalendarHeight(viewModel: viewModel)
        
        let calendarView = TSCalendarView(viewModel: viewModel)
            .environment(\.calendarAppearance, appearance)
            .id(config.id)
        hostingController.rootView = AnyView(calendarView)
    }
}
