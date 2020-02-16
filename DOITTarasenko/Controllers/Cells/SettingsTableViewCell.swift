//
//  SettingsTableViewCell.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/15/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    
    func setup(with setting: SortingTask) {
        titleLabel.text = setting.rawValue
    }
}
