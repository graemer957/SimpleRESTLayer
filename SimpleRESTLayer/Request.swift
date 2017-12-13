//
//  Request.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Optimised Labs Ltd. All rights reserved.
//

import Foundation

public struct Request {
    // MARK: - Enums
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: - Methods
    public static func with(_ address: String,
                            method: HTTPMethod = .get,
                            urlParameters: [String: String]? = nil) -> URLRequest {
        guard var urlComponents = URLComponents(string: address) else {
            preconditionFailure("Could not build URLComponents from address")
        }
        if let urlParameters = urlParameters {
            urlComponents.setQueryItems(from: urlParameters)
        }
        guard let URL = urlComponents.url else { preconditionFailure("Could not get .url from URLComponents") }
        
        var request = URLRequest(url: URL)
        request.httpMethod = method.rawValue
        
        return request
    }
}

public extension URLRequest {
    public mutating func addHeaders(_ headers: [String: String]) {
        headers.forEach { addValue($0.value, forHTTPHeaderField: $0.key) }
    }
    
    public mutating func addFormURLEncodedBody(_ body: [String: String]) {
        var components = URLComponents()
        components.setQueryItems(from: body)
        
        if let urlEncodedBodyParameters = components.percentEncodedQuery {
            addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            httpBody = urlEncodedBodyParameters.data(using: .utf8)
        }
    }
    
    public mutating func addJSONBody<T: Encodable>(_ body: T, with encoder: JSONEncoder = JSONEncoder()) throws {
        let data = try encoder.encode(body)
        addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        httpBody = data
    }
}

extension URLComponents {
    mutating func setQueryItems(from dictionary: [String: String]) {
        queryItems = dictionary.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
