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
    public typealias Handler<T> = (Response<T>) -> Void
    
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
        
        session.dataTask(with: request) { data, response, error in
            self.dump(request: request, response: response)
            guard !self.errorOccured(error: error, completion: completion) else { return }
            guard let response = response as? HTTPURLResponse else {
                completion(.init(.invalidHTTPResponse))
                return
            }
            
            switch response.statusCode {
            case 200...204:
                guard let data = data else { preconditionFailure("Unable to unwrap data") }
                self.parse(data: data, response: response, completion: completion)
            default:
                let errorCode = ResponseError.Code(rawValue: response.statusCode) ?? .unhandled
                if errorCode == .unhandled {
                    self.dump("Unhandled HTTP response code : \(response.statusCode)")
                }
                
                completion(.init(errorCode))
            }
        }.resume()
    }
    
    // MARK: - Private methods
    private func errorOccured<T>(error: Error?, completion: Handler<T>) -> Bool {
        guard let error = error else { return false }
        guard let urlError = error as? URLError else {
            completion(.init(.unhandled, message: error.localizedDescription))
            return true
        }
        
        switch urlError.code {
        case .notConnectedToInternet, .timedOut, .cannotConnectToHost:
            completion(.init(.connectionError,
                             message: "Check internet connection and try again."))
        default:
            dump("Unhandled URLError \(urlError.code), reason: \(error.localizedDescription)")
            completion(.init(.unhandled, message: error.localizedDescription))
        }
        
        return true
    }
    
    private func parse<T: Decodable>(data: Data, response: HTTPURLResponse, completion: Handler<T>) {
        do {
            let decoder = JSONDecoder()
            let model = try decoder.decode(T.self, from: data)
            
            completion(.init(model, headers: response.allHeaderFields))
        } catch let error as ResponseError {
            completion(.failure(error))
        } catch DecodingError.dataCorrupted(_) {
            completion(.init(.invalidJSON))
        } catch let DecodingError.keyNotFound(key, _) {
            completion(.init(.parseError, message: "key not found : \(key)"))
        } catch {
            completion(.init(.unhandled, message: "Error parsing: \(error)"))
        }
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
    
    private func dump(request: URLRequest, response: URLResponse?) {
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
