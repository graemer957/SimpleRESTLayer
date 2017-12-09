//
//  APIController.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 14/08/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation
import SimpleRESTLayer

final class APIController {
    // MARK: - Properties
    let client = RESTClient()
    
    // MARK: - Structs
    fileprivate struct URL {
        private static let baseAddress = "https://httpbin.org/"
        
        /// Returns the IP that the request came in from
        // swiftlint:disable identifier_name
        static let IP = baseAddress + "ip"
        // swiftlint:enable identifier_name
        
        static let Headers = baseAddress + "headers"
        
        static let Post = baseAddress + "post"
    }
    
    // MARK: - Instance methods
    func getIP(completion: @escaping (Response<IP>) -> Void) {
        // See https://httpbin.org/ip
        let request = Request.with(
            method: .get,
            address: URL.IP
        )
        client.execute(request: request, handler: completion)
    }
    
    func getHeaders(completion: @escaping (Response<[String: String]>) -> Void) {
        // See https://httpbin.org/headers
        var request = Request.with(
            method: .get,
            address: URL.Headers
        )
        request.addHeaders(["custom-header": "your value here"])
        client.execute(request: request) { (response: Response<Headers>) in
            switch response {
            case .success(let response):
                completion(.success(model: response.model.dictionary, headers: response.headers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func postJSON(_ headers: Headers, completion: @escaping (Response<JSONResponse>) -> Void) throws {
        var request = Request.with(
            method: .post,
            address: URL.Post
        )
        try request.addJSONBody(headers)
        client.execute(request: request, handler: completion)
    }
    
    func postFormURLEncoded(_ parameters: [String: String], completion: @escaping (Response<FormResponse>) -> Void) {
        var request = Request.with(
            method: .post,
            address: URL.Post
        )
        request.addFormURLEncodedBody(parameters)
        client.execute(request: request, handler: completion)
    }
}
