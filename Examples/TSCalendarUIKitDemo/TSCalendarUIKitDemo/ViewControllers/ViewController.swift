//
//  ViewController.swift
//  TSCalendarUIKitDemo
//
//  Created by TAE SU LEE on 1/13/25.
//

import UIKit
import TSCalendar

class ViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let items = [
        "FullSizeCalendarView",
        "FullSizeStaticCalendarView",
        "FixedWeekHeightCalendarView",
        "CustomHeaderCalendarView"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        navigationItem.title = "Select Calendar"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController: UIViewController
        switch indexPath.row {
        case 0:
            viewController = FullSizeCalendarViewController()
        case 1:
            viewController = FullSizeStaticCalendarViewController()
        case 2:
            viewController = FixedWeekHeightCalendarViewController()
        case 3:
            viewController = CustomHeaderCalendarViewController()
        default:
            return
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
