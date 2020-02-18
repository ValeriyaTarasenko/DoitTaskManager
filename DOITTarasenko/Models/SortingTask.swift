//
//  SortingTask.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/13/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

enum SortingTask: String, CaseIterable {
    case nameUp = "title asc"
    case nameDown = "title desc"
    case priorityUp = "priority asc"
    case priorityDown = "priority desc"
    case dateUp = "dueBy asc"
    case dateDown = "dueBy desc"
}
