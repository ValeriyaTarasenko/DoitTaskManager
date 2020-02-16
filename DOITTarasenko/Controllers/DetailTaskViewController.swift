//
//  DetailTaskViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/13/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class DetailTaskViewController: BasicViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priorityLabel: UILabel!
    
    var task: TaskModel?
    var id: Int?
    var notification: UserNotification?
    weak var taskListDelegate: TaskListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBarButtons()
        getTask()
    }
    
    private func setBarButtons() {
        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTask))
        self.navigationItem.setRightBarButtonItems([editBarButtonItem], animated: true)
    }
    
    private func getTask() {
        guard let id = id else { return }
        taskManager?.detailTask(id: id) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(task):
                self.task = task
                self.setup(task)
            case let .failure(error):
                self.handleError(error)
            }
        }
    }
    
    private func setup(_ task: TaskModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        let dueDate = Date(timeIntervalSince1970: task.dueBy)
        dateLabel.text = dateFormatter.string(from: dueDate)
        titleLabel.text = task.title
        priorityLabel.text = task.priorityValue.description
    }
    
    @IBAction private func deleteTaskButtonTap(_ sender: Any) {
        showConfirmationAlert(title: nil,
            message: "Do you want to delete task?",
            firstAction: {
                guard let id = self.id else { return }
                self.taskManager?.deleteTask(id: id) { [weak self] (result) in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(_):
                        self.taskListDelegate?.updateTaskList()
                        self.navigationController?.popViewController(animated: true)
                    case let .failure(error):
                        self.handleError(error)
                    }
            }
        })
    }
    
    @objc private func editTask() {
        let storyboard = UIStoryboard(name: "EditTask" , bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "NewTaskViewController") as? NewTaskViewController else { return }
        controller.taskListDelegate = self
        controller.task = task
        controller.notification = notification
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension DetailTaskViewController: TaskListDelegate {
    func updateTaskList() {
        getTask()
        taskListDelegate?.updateTaskList()
    }
}
