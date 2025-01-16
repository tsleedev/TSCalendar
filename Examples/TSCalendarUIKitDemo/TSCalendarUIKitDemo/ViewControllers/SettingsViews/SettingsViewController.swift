//
//  SettingsViewController.swift
//  TSCalendarUIKitDemo
//
//  Created by TAE SU LEE on 1/15/25.
//

import UIKit
import SwiftUI
import TSCalendar

class SettingsViewController: UITableViewController {
    @ObservedObject var controller: CalendarController
    
    private struct PickerItem {
        let title: String
        let options: [String]
        let selectedIndex: Int
        let onSelect: (Int) -> Void
    }
    
    private enum SettingItem {
        case picker(PickerItem)
        case toggle(
            title: String,
            isOn: Bool,
            onToggle: (Bool) -> Void
        )
    }
    
    private lazy var sections: [[SettingItem]] = {
        let displayModeOptions = TSCalendarDisplayMode.allCases.map { $0.description }
        let startWeekDayOptions = TSCalendarStartWeekDay.allCases.map { $0.description }
        let scrollDirectionOptions = TSCalendarScrollDirection.allCases.map { $0.description }
        
        return [[
            .picker(PickerItem(
                title: "Display Mode",
                options: displayModeOptions,
                selectedIndex: TSCalendarDisplayMode.allCases.firstIndex(of: controller.config.displayMode) ?? 0,
                onSelect: { [weak self] index in
                    self?.controller.config.displayMode = TSCalendarDisplayMode.allCases[index]
                }
            )),
            .picker(PickerItem(
                title: "Start of Week",
                options: startWeekDayOptions,
                selectedIndex: TSCalendarStartWeekDay.allCases.firstIndex(of: controller.config.startWeekDay) ?? 0,
                onSelect: { [weak self] index in
                    self?.controller.config.startWeekDay = TSCalendarStartWeekDay.allCases[index]
                }
            )),
            .picker(PickerItem(
                title: "Scroll Direction",
                options: scrollDirectionOptions,
                selectedIndex: TSCalendarScrollDirection.allCases.firstIndex(of: controller.config.scrollDirection) ?? 0,
                onSelect: { [weak self] index in
                    self?.controller.config.scrollDirection = TSCalendarScrollDirection.allCases[index]
                }
            )),
            .toggle(
                title: "Show Week Numbers",
                isOn: controller.config.showWeekNumber,
                onToggle: { [weak self] isOn in
                    self?.controller.config.showWeekNumber = isOn
                }
            )
        ]]
    }()
    
    init(controller: CalendarController) {
        self.controller = controller
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Calendar Settings"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = sections[indexPath.section][indexPath.row]
        
        switch item {
        case .picker(let pickerItem):
            cell.textLabel?.text = pickerItem.title
            cell.detailTextLabel?.text = pickerItem.options[pickerItem.selectedIndex]
            cell.accessoryType = .disclosureIndicator
            
        case .toggle(let title, let isOn, _):
            cell.textLabel?.text = title
            let toggle = UISwitch()
            toggle.isOn = isOn
            toggle.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            toggle.tag = indexPath.row
            cell.accessoryView = toggle
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section][indexPath.row]
        if case .picker(let pickerItem) = item {
            let pickerVC = PickerViewController(
                title: pickerItem.title,
                options: pickerItem.options,
                selectedIndex: pickerItem.selectedIndex,
                onSelect: pickerItem.onSelect
            )
            navigationController?.pushViewController(pickerVC, animated: true)
        }
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        if case .toggle(_, _, let onToggle) = sections[0][sender.tag] {
            onToggle(sender.isOn)
        }
    }
}

// MARK: - Picker View Controller
private class PickerViewController: UITableViewController {
    private let title_: String
    private let options: [String]
    private let selectedIndex: Int
    private let onSelect: (Int) -> Void
    
    init(title: String, options: [String], selectedIndex: Int, onSelect: @escaping (Int) -> Void) {
        self.title_ = title
        self.options = options
        self.selectedIndex = selectedIndex
        self.onSelect = onSelect
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = title_
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect(indexPath.row)
        navigationController?.popViewController(animated: true)
    }
}
