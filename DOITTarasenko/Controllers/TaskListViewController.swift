//
//  TaskListViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/12/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu

protocol TaskListDelegate: class  {
    func updateTaskList()
}

class TaskListViewController: BasicViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var sortBarButton: UIBarButtonItem!
    
    private var tasks = [TaskModel]()
    private var taskContainer: TaskContainer?
    private var refreshControl = UIRefreshControl()
    private let items = SortingTask.allValues.map { $0.rawValue }
    private var sort = SortingTask.nameUp
    private var notifications = [UserNotification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotifications()
        configurateView()
    }
    
    func getTasks(page: Int) {
        taskManager?.getTasks(page: page, sort: sort.rawValue) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(taskContainer):
                self.taskContainer = taskContainer
                self.tasks += taskContainer.tasks
                self.refreshControl.endRefreshing()
                self.addNotificationToTask()
                self.tableView.reloadData()
            case let .failure(error):
                self.handleError(error)
            }
        }
    }
    
    @IBAction private func addNewTaskButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "EditTask" , bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "NewTaskViewController") as? NewTaskViewController else { return }
        controller.taskListDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction private func notificationBarButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "UserNotifications" , bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "UserNotifications") as? NotificationsViewController else { return }
        controller.taskListDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func settingsBarButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings" , bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func getNotifications() {
        notificationManager?.getAllNotifications() { [weak self] notifications in
            self?.notifications = notifications
            self?.getTasks(page: 1)
        }
    }
    
    private func addNotificationToTask() {
        notifications.forEach { notification in
            if let task = tasks.first(where: {$0.id == notification.id}) {
                task.notification = notification
            }
        }
    }
    
    private func configurateView() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = UIView()
        
        if let sort = taskManager?.receiveSettings() {
            self.sort = sort
        }
        guard let view = self.navigationController?.view else { return }
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: view, title: sort.rawValue, items: items)
        self.navigationItem.rightBarButtonItem?.customView = menuView
        menuView.didSelectItemAtIndexHandler = { [weak self] (indexPath: Int) -> () in
            self?.tasks = []
            if SortingTask.allValues.indices.contains(indexPath) {
                self?.sort = SortingTask.allValues[indexPath]
            }
            self?.getTasks(page: 1)
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        tasks = []
        getTasks(page: 1)
    }
}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListTableViewCell", for: indexPath) as? TaskListTableViewCell else { return UITableViewCell() }
        cell.setup(with: tasks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tasks.count - 1,
            let currentPage = taskContainer?.meta.current,
            let meta = taskContainer?.meta,
            (meta.count/meta.limit + 1) > currentPage {
            getTasks(page: currentPage + 1)
        }
    }
}

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "DetailTask" , bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "DetailTask") as? DetailTaskViewController,
            tasks.indices.contains(indexPath.row) else { return }
        controller.id = tasks[indexPath.row].id
        controller.notification = tasks[indexPath.row].notification
        controller.taskListDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}
 
extension TaskListViewController: TaskListDelegate {
    func updateTaskList() {
        tasks = []
        getNotifications()
    }
}

