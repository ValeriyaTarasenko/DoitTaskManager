//
//  AppError.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/11/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

enum AppError: Error {
    case unknown, failed, custom(String), noToken, expiredToken
    
    var localizedDescription: String {
        switch self {
        case .unknown: return "Unknown error!"
        case .failed: return "Error!"
        case .custom(let text): return text
        case .noToken: return "No Token!"
        case .expiredToken: return "Expired token"
        }
    }
}
