//
//  NotificationTableViewCell.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/14/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    func setup(with notification: UserNotification) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        let dateInterval = Date(timeIntervalSince1970: notification.dateInterval)
        
        titleLabel.text = notification.body
        dateLabel.text = dateFormatter.string(from: dateInterval)
    }
    
}
