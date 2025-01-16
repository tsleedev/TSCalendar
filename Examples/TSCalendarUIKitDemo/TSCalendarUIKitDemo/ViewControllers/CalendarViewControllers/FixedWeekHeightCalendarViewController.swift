//
//  FixedWeekHeightCalendarViewController.swift
//  TSCalendarUIKitDemo
//
//  Created by TAE SU LEE on 1/15/25.
//

import UIKit
import TSCalendar

class FixedWeekHeightCalendarViewController: UIViewController {
    private let controller = CalendarController(
        config: TSCalendarConfig(
            heightStyle: .fixed(60),
            scrollDirection: .vertical
        )
    )
    
    private lazy var calendarView: TSCalendarUIView = {
        let calendar = TSCalendarUIView(
            config: controller.config,
            delegate: controller,
            dataSource: controller
        )
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private lazy var testLabel: UILabel = {
        let label = UILabel()
        label.text = "테스트"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = "FixedWeekHeightCalendar"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonTapped)
        )
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(calendarView)
        view.addSubview(testLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            testLabel.topAnchor.constraint(equalTo: calendarView.bottomAnchor),
            testLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            testLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController(controller: controller)
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
}
