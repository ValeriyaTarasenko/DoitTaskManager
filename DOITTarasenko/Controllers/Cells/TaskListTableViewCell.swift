//
//  TaskListTableViewCell.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/12/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class TaskListTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priorityLabel: UILabel!
    
    func setup(with task: TaskModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let dueDate = Date(timeIntervalSince1970: task.dueBy)
        
        nameLabel.text = task.title
        dateLabel.text = dateFormatter.string(from: dueDate)
        priorityLabel.text = task.priorityValue.description
    }

}
