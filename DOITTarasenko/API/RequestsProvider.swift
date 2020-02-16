//
//  RequestsProvider.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/11/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import Moya

let RequestsProvider = MoyaProvider<Requests>()

public enum Requests {
    case signUp(String, String)
    case login(String, String)
    case tasks(String, Int, String)
    case newTasks(String, TaskModel)
    case detailTask(String, Int)
    case deleteTask(String, Int)
    case updateTask(String, TaskModel)
}

extension Requests: TargetType {
   
    public var baseURL: URL {
        return URL(string: "https://testapi.doitserver.in.ua/api")!
    }
    
    public var path: String {
        switch self {
        case .signUp: return "/users"
        case .login: return "/auth"
        case .tasks, .newTasks: return "/tasks"
        case .detailTask(_, let id), .deleteTask(_, let id):
            return "/tasks/\(id)"
        case .updateTask(_, let task):
            return "/tasks/\(task.id)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .signUp, .login, .newTasks:
            return .post
        case .tasks, .detailTask:
            return .get
        case .deleteTask:
            return .delete
        case .updateTask:
            return .put
        }
    }
    
    public var parameters: [String : Any]? {
        var params: [String: Any] = [:]
        switch self {
        case .signUp(let mail, let password), .login(let mail, let password):
            params = ["email": mail, "password": password]
        case .tasks(_, let page, let sort):
            params = ["page": page, "sort": sort]
        case .detailTask, .deleteTask:
            params = [:]
        case .newTasks(_, let taskModel), .updateTask(_, let taskModel):
            params["query"] = [:]
            params["body"] = ["title": taskModel.title, "dueBy": taskModel.dueBy, "priority": taskModel.priorityValue.rawValue]
        }
        return params
    }
    
    public var task: Task {
        return .requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var headers: [String : String]? {
        switch self {
        case .tasks(let token, _, _), .newTasks(let token, _), .detailTask(let token, _),
             .deleteTask(let token, _), .updateTask(let token, _):
            return ["Authorization": "Bearer \(token)", "Content-Type": "application/json"]
        default:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch self {
        case .newTasks, .updateTask:
            return Composite()
        default:
            return URLEncoding.default
        }
    }
    
}
