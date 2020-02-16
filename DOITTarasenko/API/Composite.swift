//
//  Composite.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/13/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import Alamofire

class Composite: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        guard let parameters = parameters else {
            return try urlRequest.asURLRequest()
        }
        if parameters.isEmpty {
            return try urlRequest.asURLRequest()
        }
        
        let queryParameters = (parameters["query"] as? Parameters)
        let queryRequest = try URLEncoding(destination: .queryString).encode(urlRequest, with: queryParameters)
        
        if let body = parameters["body"] {
            let bodyParameters = (body as? Parameters)
            var bodyRequest = try JSONEncoding().encode(urlRequest, with: bodyParameters)
            
            bodyRequest.url = queryRequest.url
            return bodyRequest
        } else {
            return queryRequest
        }
    }
}
