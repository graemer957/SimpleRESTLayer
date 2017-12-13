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
    func getIP(completionHandler: @escaping (Result<IP>) -> Void) {
        // See https://httpbin.org/ip
        let request = Request.with(URL.IP)
        client.execute(request, completionHandler: completionHandler)
    }
    
    func getHeaders(completionHandler: @escaping (Result<[String: String]>) -> Void) {
        // See https://httpbin.org/headers
        var request = Request.with(URL.Headers)
        request.addHeaders(["custom-header": "your value here"])
        client.execute(request) { (result: Result<Headers>) in
            switch result {
            case let .success((response, model)):
                completionHandler(.success(response, model.dictionary))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func postJSON(_ headers: Headers, completionHandler: @escaping (Result<JSONResponse>) -> Void) throws {
        // See https://httpbin.org
        var request = Request.with(URL.Post, method: .post)
        try request.addJSONBody(headers)
        client.execute(request, completionHandler: completionHandler)
    }
    
    func postFormURLEncoded(_ parameters: [String: String],
                            completionHandler: @escaping (Result<FormResponse>) -> Void) {
        // See https://httpbin.org
        var request = Request.with(URL.Post, method: .post)
        request.addFormURLEncodedBody(parameters)
        client.execute(request, completionHandler: completionHandler)
    }
    
    func getData(bytes: Int, completionHandler: @escaping (Result<Data>) -> Void) {
        // See https://httpbin.org
        let request = Request.with(URL.Data(bytes: bytes))
        client.execute(request, completionHandler: completionHandler)
    }
    
    func getStatus(status: Int, completionHandler: @escaping (Result<Data>) -> Void) {
        // See https://httpbin.org
        let request = Request.with(URL.Status(status))
        client.execute(request, completionHandler: completionHandler)
    }
}
