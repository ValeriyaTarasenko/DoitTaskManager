//
//  SettingsViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/15/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class SettingsViewController: BasicViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let sortingTask = SortingTask.allCases
    var sortType = SortingTask.nameUp
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setBarButtons()
        guard let sort = taskManager?.receiveSettings() else { return }
        sortType = sort
    }
    
    private func setBarButtons() {
        let editBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutTap))
        self.navigationItem.setRightBarButtonItems([editBarButtonItem], animated: true)
    }

    @objc private func logoutTap() {
        showConfirmationAlert(title: nil,
            message: "Do you want to logout?",
            firstAction: {
                self.logout()
        })
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortingTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as? SettingsTableViewCell, sortingTask.indices.contains(indexPath.row) else { return UITableViewCell() }
        cell.setup(with: sortingTask[indexPath.row])
        cell.accessoryType = sortType == sortingTask[indexPath.row] ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard sortingTask.indices.contains(indexPath.row) else { return }
        sortType = sortingTask[indexPath.row]
        taskManager?.saveSettings(sortType)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.reloadData()
    }
}
