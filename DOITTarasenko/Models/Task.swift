//
//  Task.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/12/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

public class TaskModel: Codable {
    let id: Int
    var title: String
    var dueBy: TimeInterval
    var notification: UserNotification? 
    var priorityValue: Priority {
        return Priority.init(rawValue: priority) ?? .low
    }
    
    private var priority: String
    
    init(id: Int, title: String, priority: String, dueBy: TimeInterval, notification: UserNotification? = nil) {
        self.id = id
        self.title = title
        self.priority = priority
        self.dueBy = dueBy
        self.notification = notification
    }
    
    func updatePriority(_ priority: Priority) {
        self.priority = priority.rawValue
    }
    
    enum Priority: String, CaseIterable {
        case low = "Low"
        case medium = "Normal"
        case high = "High"
        
        var description: String {
            switch self {
            case .high:
                return "↑ \(rawValue)"
            case .medium:
                return "Medium"
            case .low:
                return "↓ \(rawValue)"
            }
        }
    }
}

struct TaskMeta: Codable {
    var current: Int
    var limit: Int
    var count: Int
}

struct TaskContainer: Codable {
    let tasks: [TaskModel]
    var meta: TaskMeta
}


