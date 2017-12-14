//
//  RESTClient.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Optimised Labs Ltd. All rights reserved.
//

import Foundation
import Dispatch

public struct RESTClient {
    // MARK: - Properties
    private let configuration: URLSessionConfiguration
    private var session: URLSession
    var queue: DispatchQueue = .main
    var authorisation = Authorisation.none { didSet { updateAuthorisationHeader() }}
    
    // MARK: - Structs
    private struct Constants {
        static let defaultHeaders = [
            "Accept": "application/json; charset=utf-8",
            "Accept-Encoding": "gzip"
        ]
    }
    
    // MARK: - Enums
    enum Authorisation {
        case none
        case basic(username: String, password: String)
        case bearer(token: String)
    }
    
    // MARK: - Initialiser
    public init(appName: String? = nil,
                headers: [AnyHashable: Any]? = nil,
                timeout: TimeInterval = 60) {
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
    public func execute<T>(_ request: URLRequest,
                           with decoder: JSONDecoder = JSONDecoder(),
                           completionHandler: @escaping (Result<T>) -> Void) {
        #if os(Linux)
        // See https://gitlab.com/optimisedlabs/URLSessionRegression
        let session = URLSession(configuration: configuration)
        #endif
        
        dump(request: request)
        session.dataTask(with: request) { data, urlResponse, error in
            self.dump(response: urlResponse)
            
            do {
                if let error = error { throw error }
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else { throw ResponseError.invalid }
                let response = try httpResponse.makeResponse()
                
                // As per the documentation, the request has not errored so `data` will be some, even if zero bytes
                guard response.status.isSuccessful() else { throw ResponseError.unsuccessful(response, data!) }
                let model = try data!.decode(T.self, using: decoder)
                self.queue.async { completionHandler(.success(response, model)) }
            } catch {
                self.queue.async { completionHandler(.failure(error)) }
            }
        }.resume()
    }
    
    // MARK: - Private methods
    private func dump(_ text: String) {
        #if DEBUG
            print("\(Date()) [RESTClient] \(text)")
        #endif
    }
    
    private func dumpAllConfigurationHeaders() {
        #if DEBUG
            if let headers = configuration.httpAdditionalHeaders as? [String: String] {
                dump("Configuration headers : \(headers)")
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
    
    private func dump(response: URLResponse?) {
        guard let response = response as? HTTPURLResponse else { return }
        
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

// MARK: - Authorisation
extension RESTClient {
    private mutating func updateAuthorisationHeader() {
        switch authorisation {
        case .none:
            configuration.authorisationHeader = nil
        case let .basic(username: username, password: password):
            guard let credentials = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
                preconditionFailure("Unable to base64 encode email and password")
            }
            configuration.authorisationHeader = "Basic \(credentials)"
        case let .bearer(token: token):
            configuration.authorisationHeader = "Bearer \(token)"
        }
        session = URLSession(configuration: configuration)
        dumpAllConfigurationHeaders()
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
    
    fileprivate var authorisationHeader: String? {
        get { return httpAdditionalHeaders?["Authorization"] as? String }
        set { httpAdditionalHeaders?["Authorization"] = newValue }
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

extension Data {
    fileprivate func decode<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder) throws -> T {
        if let data = self as? T {
            return data
        }
        
        return try decoder.decode(type, from: self)
    }
}
