//
//  FullSizeStaticCalendarViewController.swift
//  TSCalendarUIKitDemo
//
//  Created by TAE SU LEE on 1/15/25.
//

import UIKit
import TSCalendar

class FullSizeStaticCalendarViewController: UIViewController {
    private let controller = CalendarController(
        config: TSCalendarConfig(
            isPagingEnabled: false,
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = "FullSizeStaticCalendar"
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
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController(controller: controller)
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
}
