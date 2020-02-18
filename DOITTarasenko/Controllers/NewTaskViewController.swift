//
//  NewTaskViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/12/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class NewTaskViewController: BasicViewController {
    @IBOutlet private weak var titleTextView: UITextView!
    @IBOutlet private var priorityButtons: [UIButton]!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var dateTextField: UITextField!
    @IBOutlet private weak var notificationTextField: UITextField!
    @IBOutlet private weak var deleteNotificationButton: UIButton!
    
    var task: TaskModel?
    var notification: UserNotification?
    weak var taskListDelegate: TaskListDelegate?
    private var priority: TaskModel.Priority = .high
    private var dateInterval: TimeInterval?
    private var notificationDate: TimeInterval?
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        return dateFormatter
    }
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.minimumDate = Date()
        return picker
    }()
    
    private let notificationDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.minimumDate = Date()
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        titleTextView.layer.borderColor = UIColor.lightGray.cgColor
        titleTextView.layer.borderWidth = 1
        
        priorityButtons.forEach({
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.layer.borderWidth = 1
        })
        
        addDatePicker()
        setPriority()
        setup() 
        deleteButton.isHidden = task == nil
    }
    
    @IBAction private func priorityButtonTap(_ sender: UIButton) {
        guard TaskModel.Priority.allCases.indices.contains(sender.tag) else { return }
        priority = TaskModel.Priority.allCases[sender.tag]
        setPriority()
    }
    
    @IBAction private func deleteButtonTap(_ sender: Any) {
        showConfirmationAlert(title: nil,
           message: "Do you want to delete task?",
           firstAction: {
            guard let task = self.task else { return }
            self.taskManager?.deleteTask(id: task.id) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .success(_):
                    self.notificationManager?.deleteNotification(task.id)
                    self.taskListDelegate?.updateTaskList()
                    self.navigationController?.popToRootViewController(animated: true)
                case let .failure(error):
                    self.handleError(error)
                }
            }
        })
    }
    
    @IBAction private func saveButtonTap(_ sender: Any) {
        guard let title = titleTextView.text, !title.isEmpty,
            let dateInterval = dateInterval else {
                return self.showErrorMessage("Please, fill all fields")
        }
        _ = task == nil ? createNewTask(title: title, dateInterval: dateInterval) : updateTask(title: title, dateInterval: dateInterval)
        
    }
    
    @IBAction private func deleteNotificationButtonTap(_ sender: Any) {
        notificationDate = nil
        notificationTextField.text = ""
        if let task = task {
            notificationManager?.deleteNotification(task.id)
        }
    }
    
    private func setup() {
        guard let task = task else { return }
        titleTextView.text = task.title
        priority = task.priorityValue
        dateInterval = task.dueBy
        datePicker.date = Date(timeIntervalSince1970: task.dueBy)
        handleDatePicker()
        setPriority()
        guard let notification = notification else { return }
        notificationDate = notification.dateInterval
        notificationDatePicker.date = Date(timeIntervalSince1970: notification.dateInterval)
        handleNotificationDatePicker()
    }
    
    private func addDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDatePicker))
        toolbar.setItems([doneButton], animated: false)
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        
        let toolbarNotification = UIToolbar()
        toolbarNotification.sizeToFit()
        let doneNotificationButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleNotificationDatePicker))
        toolbarNotification.setItems([doneNotificationButton], animated: false)
        notificationTextField.inputAccessoryView = toolbarNotification
        notificationTextField.inputView = notificationDatePicker
        
    }
    
    private func setPriority() {
        guard let index = TaskModel.Priority.allCases.firstIndex(where: {$0 == priority}) else { return }
        priorityButtons.forEach({button in
            if button.tag == index {
                button.backgroundColor = .orange
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .white
                button.setTitleColor(.black, for: .normal)
            }
        })
    }
    
    private func createNewTask(title: String, dateInterval: TimeInterval) {
        let task = TaskModel(id: 0, title: title, priority: priority.rawValue, dueBy: dateInterval)
        taskManager?.addTask(task: task) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(task):
                if let notificationDate = self.notificationDate {
                    let notification = UserNotification(id: task.id, body: task.title, dateInterval: notificationDate)
                    self.notificationManager?.newNotification(notification)
                }
                self.taskListDelegate?.updateTaskList()
                self.navigationController?.popViewController(animated: true)
            case let .failure(error):
                self.handleError(error)
            }
        }
    }
    
    private func updateTask(title: String, dateInterval: TimeInterval) {
        guard let task = self.task else { return }
        task.title = title
        task.dueBy = dateInterval
        task.updatePriority(self.priority)
        self.taskManager?.updateTask(task: task) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                if let notificationDate = self.notificationDate {
                    let notification = UserNotification(id: task.id, body: task.title, dateInterval: notificationDate)
                    self.notificationManager?.deleteNotification(task.id)
                    self.notificationManager?.newNotification(notification)
                }
                self.taskListDelegate?.updateTaskList()
                self.navigationController?.popViewController(animated: true)
            case let .failure(error):
                self.handleError(error)
            }
        }
    }
    
    @objc private func handleDatePicker() {
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        dateTextField.resignFirstResponder()
        dateInterval = datePicker.date.timeIntervalSince1970
        
        notificationDatePicker.maximumDate = datePicker.date
        notificationDatePicker.date = datePicker.date
    }
    
    @objc private func handleNotificationDatePicker() {
        if dateInterval == nil {
            notificationTextField.resignFirstResponder()
            return showErrorMessage("Please, fill date field")
        }
        notificationTextField.text = dateFormatter.string(from: notificationDatePicker.date)
        notificationTextField.resignFirstResponder()
        notificationDate = notificationDatePicker.date.timeIntervalSince1970
    }
}
