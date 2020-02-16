//
//  TaskManager.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/12/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import Swinject
import SwiftKeychainWrapper

protocol TaskManager {
    func getTasks(page: Int, sort: String, completionHandler: @escaping (Result<TaskContainer, AppError>) -> Void)
    func addTask(task: TaskModel, completionHandler: @escaping (Result<TaskModel, AppError>) -> Void)
    func detailTask(id: Int, completionHandler: @escaping (Result<TaskModel, AppError>) -> Void)
    func deleteTask(id: Int, completionHandler: @escaping (Result<Bool, AppError>) -> Void)
    func updateTask(task: TaskModel, completionHandler: @escaping (Result<Bool, AppError>) -> Void)
    func logout()
    func saveSettings(_ sort: SortingTask)
    func receiveSettings() -> SortingTask
}

class TaskManagerImplementation: TaskManager {
    private var userManager: UserManager
    private struct TaskDecode: Codable {
        let task: TaskModel
    }
    
    private struct Constans {
        static var sorting = "sorting"
    }
    
    init(userManager: UserManager) {
        self.userManager = userManager
    }
    
    convenience init(resolver: Resolver) {
        let userManager = resolver.resolve(UserManager.self)!
        self.init(userManager: userManager)
    }
    
    func getTasks(page: Int, sort: String, completionHandler: @escaping (Result<TaskContainer, AppError>) -> Void) {
        guard let user = userManager.user else { return completionHandler(.failure(.noToken))}
        let parameter: Requests = .tasks(user.token, page, sort)
        RequestsProvider.request(parameter) { result in
            let response = try? result.get()
            guard let data = response?.data else { return completionHandler(.failure(.unknown))}
            if let error = self.userManager.handleApiError(data: data) {
                completionHandler(.failure(error))
            } else {
                do {
                    let taskContainer = try TaskContainer.decode(data: data)
                    completionHandler(.success(taskContainer))
                } catch let error {
                    completionHandler(.failure(.custom(error.localizedDescription)))
                }
            }
        }
    }
    
    func addTask(task: TaskModel, completionHandler: @escaping (Result<TaskModel, AppError>) -> Void) {
        guard let user = userManager.user else { return completionHandler(.failure(.noToken))}
        let parameter: Requests = .newTasks(user.token, task)
        RequestsProvider.request(parameter) { result in
            let response = try? result.get()
            guard let data = response?.data else { return completionHandler(.failure(.unknown)) }
            if let error = self.userManager.handleApiError(data: data) {
                completionHandler(.failure(error))
            } else {
                do {
                    let taskDecode = try TaskDecode.decode(data: data)
                    completionHandler(.success(taskDecode.task))
                } catch let error {
                    completionHandler(.failure(.custom(error.localizedDescription)))
                }
            }
        }
    }
    
    func detailTask(id: Int, completionHandler: @escaping (Result<TaskModel, AppError>) -> Void) {
        guard let user = userManager.user else { return completionHandler(.failure(.noToken))}
        let parameter: Requests = .detailTask(user.token, id)
        RequestsProvider.request(parameter) { result in
            let response = try? result.get()
            guard let data = response?.data else { return completionHandler(.failure(.unknown)) }
            if let error = self.userManager.handleApiError(data: data) {
                completionHandler(.failure(error))
            } else {
                do {
                    let taskDecode = try TaskDecode.decode(data: data)
                    completionHandler(.success(taskDecode.task))
                } catch let error {
                    completionHandler(.failure(.custom(error.localizedDescription)))
                }
            }
        }
    }
    
    func deleteTask(id: Int, completionHandler: @escaping (Result<Bool, AppError>) -> Void) {
        guard let user = userManager.user else { return completionHandler(.failure(.noToken))}
        let parameter: Requests = .deleteTask(user.token, id)
        RequestsProvider.request(parameter) { result in
            let response = try? result.get()
            guard let data = response?.data else { return completionHandler(.failure(.unknown))}
            if let error = self.userManager.handleApiError(data: data) {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(true))
            }
        }
    }
    
    func updateTask(task: TaskModel, completionHandler: @escaping (Result<Bool, AppError>) -> Void) {
        guard let user = userManager.user else { return completionHandler(.failure(.noToken))}
        let parameter: Requests = .updateTask(user.token, task)
        RequestsProvider.request(parameter) { result in
            let response = try? result.get()
            guard let data = response?.data else { return completionHandler(.failure(.unknown))}
            if let error = self.userManager.handleApiError(data: data) {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(true))
            }
        }
    }
    
    func logout() {
        userManager.removeToken()
    }
    
    func saveSettings(_ sort: SortingTask) {
        KeychainWrapper.standard.set(sort.rawValue, forKey: Constans.sorting)
    }
    
    func receiveSettings() -> SortingTask {
        guard let sortRawValue = KeychainWrapper.standard.string(forKey: Constans.sorting),
            let sort = SortingTask(rawValue: sortRawValue) else { return .nameUp }
        return sort
    }
}
