//
//  CustomHeaderCalendarViewController.swift
//  TSCalendarUIKitDemo
//
//  Created by TAE SU LEE on 1/15/25.
//

import UIKit
import Combine
import TSCalendar

class CustomHeaderCalendarViewController: UIViewController {
    private let controller = CalendarController(
        config: TSCalendarConfig(
            heightStyle: .fixed(60),
            showHeader: false
        )
    )
    
    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var previousButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.text = controller.headerTitle
        return label
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var todayButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitle("Today", for: .normal)
        button.addTarget(self, action: #selector(todayButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(expandButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var calendarContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var calendarView: TSCalendarUIView = {
        let calendar = TSCalendarUIView(
            config: controller.config,
            delegate: controller,
            dataSource: controller
        )
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private var containerBottomConstraint: NSLayoutConstraint?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        bindHeaderTitle()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "CustomHeaderCalendar"
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonTapped)
        )
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground

        // Header Stack View
        view.addSubview(headerStackView)
        headerStackView.addArrangedSubview(previousButton)
        headerStackView.addArrangedSubview(headerTitleLabel)
        headerStackView.addArrangedSubview(nextButton)
        headerStackView.addArrangedSubview(UIView()) // Spacer
        headerStackView.addArrangedSubview(todayButton)
        headerStackView.addArrangedSubview(expandButton)

        // Calendar View
        view.addSubview(calendarContainerView)
        calendarContainerView.addSubview(calendarView)
        updateExpandButtonTitle()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header Stack View
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Calendar Container - 항상 활성화되는 제약조건들
            calendarContainerView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor),
            calendarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Calendar View - 위치 제약조건
            calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
        ])
        
        // 동적으로 변경될 제약조건들 준비
        containerBottomConstraint = calendarContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        updateContainerConstraints()
    }
    
    private func bindHeaderTitle() {
        controller.$headerTitle
            .sink { [weak self] newTitle in
                self?.headerTitleLabel.text = newTitle
            }
            .store(in: &cancellables)
    }
    
    private func updateContainerConstraints() {
        if controller.config.heightStyle.isFlexible {
            // flexible 모드: 컨테이너를 화면 끝까지
            containerBottomConstraint?.isActive = true
        } else {
            // fixed 모드: 컨테이너를 캘린더 크기만큼만
            containerBottomConstraint?.isActive = false
        }
    }
    
    private func updateExpandButtonTitle() {
        expandButton.setTitle(
            controller.config.heightStyle.isFlexible ? "Collapse" : "Expand",
            for: .normal
        )
    }
    
    @objc private func previousButtonTapped() {
        calendarView.moveToPrevious()
    }

    @objc private func nextButtonTapped() {
        calendarView.moveToNext()
    }

    @objc private func todayButtonTapped() {
        calendarView.selectDate(.now)
    }

    @objc private func expandButtonTapped() {
        controller.config.heightStyle = controller.config.heightStyle.isFlexible ? .fixed(60) : .flexible

        UIView.animate(withDuration: 0.3) {
            self.updateContainerConstraints()
            self.updateExpandButtonTitle()
            self.calendarView.reloadCalendar()
            self.view.layoutIfNeeded()
        }
    }

    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController(controller: controller)
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
}
