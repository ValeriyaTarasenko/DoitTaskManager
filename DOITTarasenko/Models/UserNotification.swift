//
//  UserNotification.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/14/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UserNotifications

struct UserNotification: Codable {
    let id: Int
    let body: String
    let dateInterval: TimeInterval
}
