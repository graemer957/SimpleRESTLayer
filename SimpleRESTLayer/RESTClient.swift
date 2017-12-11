//
//  RESTClient.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation
import Dispatch

public struct RESTClient {
    // MARK: - Typealias
    public typealias Handler<T> = (Result<T>) -> Void
    
    // MARK: - Properties
    private let configuration: URLSessionConfiguration
    private let session: URLSession
    
    // MARK: - Structs
    private struct Constants {
        static let defaultHeaders = [
            "Accept": "application/json; charset=utf-8",
            "Accept-Encoding": "gzip"
        ]
    }
    
    // MARK: - Initialiser
    public init(appName: String? = nil, headers: [AnyHashable: Any]? = nil, timeout: TimeInterval = 60) {
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.httpAdditionalHeaders = Constants.defaultHeaders
        configuration.userAgent(using: appName)
        headers?.forEach { configuration.httpAdditionalHeaders?[$0.key] = $0.value }
        configuration.timeoutIntervalForRequest = timeout
        
        self.configuration = configuration
        self.session = URLSession(configuration: configuration)
        
        dumpAllConfigurationHeaders()
    }
    
    public init(configuration: URLSessionConfiguration) {
        configuration.httpAdditionalHeaders = Constants.defaultHeaders
        
        self.configuration = configuration
        self.session = URLSession(configuration: configuration)
        
        dumpAllConfigurationHeaders()
    }
    
    // MARK: - Instance methods
    public func execute<T: Decodable>(request: URLRequest,
                                      handler: @escaping Handler<T>) {
        // Ensure all our responses are back on the main thread
        let completion = { response in DispatchQueue.main.async { handler(response) }}
        
        #if os(Linux)
        // See https://gitlab.com/optimisedlabs/URLSessionRegression
        let session = URLSession(configuration: .default)
        #endif
        
        session.dataTask(with: request) { data, urlResponse, error in
            self.dump(request, urlResponse)
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                completion(.failure(ResponseError.invalid))
                return
            }
            
            do {
                let response: Response = try urlResponse.makeResponse()
                
                switch urlResponse.statusCode {
                case 200...204 where T.self == RawResponse.self:
                    try self.parse(data: RawResponse.from(data), response: urlResponse, completion: completion)
                case 200...204:
                    guard let data = data else { throw ResponseError.noData }
                    try self.parse(data: data, response: urlResponse, completion: completion)
                default:
                    throw ResponseError.unsuccessful(response)
                }
            } catch {
                completion(.failure(error))
                return
            }
        }.resume()
    }
    
    // MARK: - Private methods
    private func parse<T: Decodable>(data: Data, response: HTTPURLResponse, completion: Handler<T>) throws {
        let decoder = JSONDecoder()
        let model = try decoder.decode(T.self, from: data)
        
        completion(.init(model, headers: response.allHeaderFields))
    }
    
    private func dump(_ text: String) {
        #if DEBUG
            print("[RESTClient] \(text)")
        #endif
    }
    
    private func dumpAllConfigurationHeaders() {
        #if DEBUG
            if let headers = configuration.httpAdditionalHeaders as? [String: String] {
                dump("Configuration headers : \(headers)")
            }
        #endif
    }
    
    private func dump(_ request: URLRequest, _ response: URLResponse?) {
        #if DEBUG
            self.dump(request: request)
            if let response = response as? HTTPURLResponse {
                self.dump(response: response)
            }
        #endif
    }
    
    private func dump(request: URLRequest) {
        dump("Request URL:\t\(request.httpMethod!) \(request.url!.absoluteString)")
        
        if let allHTTPHeaderFields = request.allHTTPHeaderFields, allHTTPHeaderFields.count > 0 {
            dump("Headers:\t\t\(allHTTPHeaderFields)")
        }
        
        if let data = request.httpBody, let body = String(bytes: data, encoding: .utf8) {
            dump("Body:\t\t\t\(body)")
        }
    }
    
    private func dump(response: HTTPURLResponse) {
        if let responseURL = response.url?.absoluteString {
            dump("Response URL:\t\(responseURL)")
        }
        dump("Status:\t\t\(response.statusCode)")
        
        if response.allHeaderFields.count > 0 {
            dump("Headers:")
            response.allHeaderFields.forEach { dump("\t\t\t\t\($0.key): \($0.value)") }
        }
    }
}

extension URLSessionConfiguration {
    fileprivate func userAgent(using appName: String?) {
        if let infoDictionary = Bundle.main.infoDictionary,
            let name = infoDictionary["CFBundleName"] as? String,
            let version = infoDictionary["CFBundleShortVersionString"] as? String,
            let build = infoDictionary["CFBundleVersion"] as? String {
            let userAgent = "\(appName ?? name) v\(version) (\(build))"
            httpAdditionalHeaders?["User-Agent"] = userAgent
        }
    }
}

extension HTTPURLResponse {
    fileprivate func makeResponse() throws -> Response {
        guard let status = Response.Status(rawValue: statusCode) else {
            throw ResponseError.undefinedStatus(statusCode)
        }
        return Response(status, headers: allHeaderFields)
    }
}
