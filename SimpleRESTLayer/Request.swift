//
//  Request.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation


public struct Request {
    // MARK: - Enums
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    
    // MARK: - Methods
    public static func with(method: HTTPMethod, address: String, headers: [String: String]? = nil, parameters: [String: String]? = nil, body: [String: String]? = nil) -> URLRequest
    {
        guard var urlComponents = URLComponents(string: address) else { fatalError("Unable to build components") }
        if let parameters = parameters {
            urlComponents.queryItems = [URLQueryItem]()
            
            for (name, value) in parameters {
                let queryItem = URLQueryItem(name: name, value: value)
                urlComponents.queryItems?.append(queryItem)
            }
        }
        
        guard let URL = urlComponents.url else { fatalError("Unable to build URL") }
        
        let request = NSMutableURLRequest(url: URL)
        switch (method) {
        case .get:
            request.httpMethod = HTTPMethod.get.rawValue
        case .post:
            request.httpMethod = HTTPMethod.post.rawValue
        }
        
        if let headers = headers {
            for (field, value) in headers {
                request.addValue(value, forHTTPHeaderField: field)
            }
        }
        
        if let body = body {
            var bodyComponents = URLComponents()
            bodyComponents.queryItems = [URLQueryItem]()
            
            for (name, value) in body {
                let queryItem = URLQueryItem(name: name, value: value)
                bodyComponents.queryItems?.append(queryItem)
            }
            
            if let urlEncodedBodyParameters = bodyComponents.percentEncodedQuery {
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = urlEncodedBodyParameters.data(using: String.Encoding.utf8)
            }
        }
        
        return request as URLRequest
    }
}
