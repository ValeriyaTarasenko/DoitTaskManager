//
//  NotificationsViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/14/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class NotificationsViewController: BasicViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var notifications = [UserNotification]()
    weak var taskListDelegate: TaskListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        notificationManager?.getAllNotifications() { [weak self] notifications in
            guard let `self` = self else { return }
            self.notifications = notifications
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as? NotificationTableViewCell, notifications.indices.contains(indexPath.row) else { return UITableViewCell() }
        cell.setup(with: notifications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, notifications.indices.contains(indexPath.row) {
            notificationManager?.deleteNotification(notifications[indexPath.row].id)
            notifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            taskListDelegate?.updateTaskList()
        }
    }
}
