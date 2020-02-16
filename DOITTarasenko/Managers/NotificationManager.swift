//
//  NotificationManager.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/14/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UserNotifications
import Swinject

protocol NotificationManager {
    func newNotification(_ userNotitication: UserNotification)
    func deleteNotification(_ id: Int)
    func getAllNotifications(completionHandler:  @escaping ([UserNotification]) -> Void) 
}

class NotificationManagerImplementation: NSObject, NotificationManager {
    private var userManager: UserManager
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init(userManager: UserManager) {
        self.userManager = userManager
    }
    
    convenience init(resolver: Resolver) {
        let userManager = resolver.resolve(UserManager.self)!
        self.init(userManager: userManager)
    }
    
    func newNotification(_ userNotitication: UserNotification) {
        let content = UNMutableNotificationContent()
        content.title = "Notification Task Manager"
        content.body = userNotitication.body
        content.sound = UNNotificationSound.default
        content.userInfo = ["email": userManager.user?.email ?? ""]
        let identifier = userNotitication.id
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date(timeIntervalSince1970: userNotitication.dateInterval))
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "\(identifier)",
          content: content, trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
    }
    
    func deleteNotification(_ id: Int) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(id)"])
    }
    
    func getAllNotifications(completionHandler: @escaping ([UserNotification]) -> Void)  {
        notificationCenter.getPendingNotificationRequests { requests in
             let notifications = requests.compactMap({ request -> UserNotification? in
                guard let userInfo = request.content.userInfo["email"] as? String,
                    let email = self.userManager.user?.email,
                    let id = Int(request.identifier),
                    let trigger = request.trigger as? UNCalendarNotificationTrigger else { return nil }
                    let dateComponents = trigger.dateComponents
                guard let date = Calendar.current.date(from: dateComponents)else { return nil }
                if userInfo == email { return UserNotification(id: id, body: request.content.body, dateInterval: date.timeIntervalSince1970)}
                return nil
            })
            completionHandler(notifications)
        }
    }
}
