//
//  APIController.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 14/08/2017.
//  Copyright © 2017 Optimised Labs Ltd. All rights reserved.
//

import Foundation
import SimpleRESTLayer

final class APIController {
    // MARK: - Properties
    let client = RESTClient()
    
    // MARK: - Structs
    private struct URL {
        private static let baseAddress = "https://httpbin.org/"
        static let IP = baseAddress + "ip"
        static let Headers = baseAddress + "headers"
        static let Post = baseAddress + "post"
        static func Data(bytes: Int) -> String {
            return baseAddress + "bytes/\(bytes)"
        }
        static func Status(_ status: Int) -> String {
            return baseAddress + "status/\(status)"
        }
    }
    
    // MARK: - Instance methods
    func getIP(completion: @escaping (Result<IP>) -> Void) {
        // See https://httpbin.org/ip
        let request = Request.with(
            method: .get,
            address: URL.IP
        )
        client.execute(request: request, handler: completion)
    }
    
    func getHeaders(completion: @escaping (Result<[String: String]>) -> Void) {
        // See https://httpbin.org/headers
        var request = Request.with(
            method: .get,
            address: URL.Headers
        )
        request.addHeaders(["custom-header": "your value here"])
        client.execute(request: request) { (result: Result<Headers>) in
            switch result {
            case let .success((response, model)):
                completion(.success(response, model.dictionary))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func postJSON(_ headers: Headers, completion: @escaping (Result<JSONResponse>) -> Void) throws {
        // See https://httpbin.org
        var request = Request.with(
            method: .post,
            address: URL.Post
        )
        try request.addJSONBody(headers)
        client.execute(request: request, handler: completion)
    }
    
    func postFormURLEncoded(_ parameters: [String: String], completion: @escaping (Result<FormResponse>) -> Void) {
        // See https://httpbin.org
        var request = Request.with(
            method: .post,
            address: URL.Post
        )
        request.addFormURLEncodedBody(parameters)
        client.execute(request: request, handler: completion)
    }
    
    func getData(bytes: Int, completion: @escaping (Result<Data>) -> Void) {
        // See https://httpbin.org
        let request = Request.with(
            method: .get,
            address: URL.Data(bytes: bytes)
        )
        client.execute(request: request, handler: completion)
    }
    
    func getStatus(status: Int, completion: @escaping (Result<Data>) -> Void) {
        // See https://httpbin.org
        let request = Request.with(
            method: .get,
            address: URL.Status(status)
        )
        client.execute(request: request, handler: completion)
    }
}
