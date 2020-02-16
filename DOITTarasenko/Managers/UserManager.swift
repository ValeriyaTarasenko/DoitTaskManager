//
//  UserManager.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/11/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

protocol UserManager {
    var user: User? { get }
    func signUp(mail: String, password: String, completionHandler: @escaping (Result<User, AppError>) -> Void)
    func login(mail: String, password: String, completionHandler: @escaping (Result<User, AppError>) -> Void)
    func removeToken()
    func handleApiError(data: Data) -> AppError?
}

class UserManagerImplementation: UserManager {
    private(set) var user: User?
    private var customKeychainWrapperInstance: KeychainWrapper?
    
    private struct Constans {
        static var token = "token"
        static var email = "email"
    }
    
    init() {
        receiveToken()
    }

    
    func signUp(mail: String, password: String, completionHandler: @escaping (Result<User, AppError>) -> Void) {
        let parameter: Requests = .signUp(mail, password)
        autentification(parameter: parameter, mail: mail) { result in
             completionHandler(result)
        }
    }
    
    func login(mail: String, password: String, completionHandler: @escaping (Result<User, AppError>) -> Void) {
        let parameter: Requests = .login(mail, password)
        autentification(parameter: parameter, mail: mail) { result in
             completionHandler(result)
        }
    }
    
    private func autentification(parameter: Requests, mail: String, completionHandler: @escaping (Result<User, AppError>) -> Void) {
        RequestsProvider.request(parameter) { result in
            let response = try? result.get()
            guard let data = response?.data else { return completionHandler(.failure(.unknown))}
            if let error = self.handleApiError(data: data) {
                completionHandler(.failure(error))
            } else {
                do {
                    var user = try User.decode(data: data)
                    user.email = mail
                    self.user = user
                    self.saveToken(mail)
                    completionHandler(.success(user))
                } catch let error {
                    completionHandler(.failure(.custom(error.localizedDescription)))
                }
            }
        }
    }
    
    func removeToken() {
        KeychainWrapper.standard.removeObject(forKey: Constans.token)
        KeychainWrapper.standard.removeObject(forKey: Constans.email)
        user = nil
    }
    
    func handleApiError(data: Data) -> AppError? {
       do {
           guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
               else { return nil }
           var title = ""
           var description = ""
           if let messageDescription = json["message"] as? String {
               title = messageDescription
               if title == "Expired token" { return .expiredToken}
           }
           if let fieldsDescription = json["fields"] as? [String: Any] {
               description = fieldsDescription.map({ key, value in
                   let values = (value as! [String]).joined(separator: ", ")
                   return "\(key): \(values)"
                   }).joined(separator: ", ")
           }
           if title.isEmpty, description.isEmpty { return nil}
           return .custom("\(title). \(description)")
       } catch {
           return .custom(error.localizedDescription)
       }
    }
    
    private func saveToken(_ email: String) {
        guard let token = user?.token else { return }
        KeychainWrapper.standard.set(token, forKey: Constans.token)
        KeychainWrapper.standard.set(email, forKey: Constans.email)
    }
    
    private func receiveToken() {
        guard let token = KeychainWrapper.standard.string(forKey: Constans.token) else { return }
        let email = KeychainWrapper.standard.string(forKey: Constans.email)
        user = User(token: token, email: email)
    }
}
