//
//  RESTClient.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation
import Dispatch

public final class RESTClient {
    // MARK: - Properties
    private let configuration: URLSessionConfiguration
    private let session: URLSession
    
    // MARK: - Initialiser
    public init(appName: String? = nil, headers: [AnyHashable: Any]? = nil, timeout: TimeInterval? = nil) {
        configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = [
            "Accept": "application/json;charset=utf-8",
            "Accept-Encoding": "gzip"
        ]
        
        if let infoDictionary = Bundle.main.infoDictionary,
        let name = infoDictionary["CFBundleName"] as? String,
        let version = infoDictionary["CFBundleShortVersionString"] as? String,
        let build = infoDictionary["CFBundleVersion"] as? String {
            let userAgent = "\(appName ?? name) v\(version) (\(build))"
            configuration.httpAdditionalHeaders?["User-Agent"] = userAgent
        }
        
        if let headers = headers {
            for (field, value) in headers {
                configuration.httpAdditionalHeaders![field] = value
            }
        }
        
        if let timeout = timeout {
            configuration.timeoutIntervalForRequest = timeout
        }
        
        session = URLSession(configuration: self.configuration)
        
        if let headers = configuration.httpAdditionalHeaders as? [String: String] {
            dump("Configuration headers : \(headers)")
        }
    }
    
    // MARK: - Instance methods
    public func execute<T: ResponseParser>(request: URLRequest,
                                           parser: T,
                                           handler: @escaping (Response<T.ParsedModel>) -> Void) {
        // Ensure all our responses are back on the main thread
        let completion = { (response: Response<T.ParsedModel>) in
            DispatchQueue.main.async {
                handler(response)
            }
        }
        
        session.dataTask(with: request, completionHandler: { data, response, error in
            #if DEBUG
                self.dump(request: request)
                if let response = response as? HTTPURLResponse {
                    self.dump(response: response)
                }
            #endif
            
            if let error = error as NSError? {
                if error.domain == NSURLErrorDomain {
                    switch error.code {
                    case NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut, NSURLErrorCannotConnectToHost:
                        completion(Response(errorCode: .connectionError,
                                            message: "Check internet connection and try again."))
                    default:
                        completion(Response(errorCode: .unhandled, message: error.localizedDescription))
                    }
                } else {
                    self.dump("Unhandled NSURLSession Error: \(error.localizedDescription): \(error.userInfo)")
                    
                    completion(Response(errorCode: .unhandled, message: error.localizedDescription))
                }
                
                return
            }
            
            guard let urlResponse = response as? HTTPURLResponse else {
                completion(Response(errorCode: .invalidHTTPResponse))
                
                return
            }
            
            if case 200...204 = urlResponse.statusCode {
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completion(Response(errorCode: .invalidJSON))
                    
                    return
                }
                
                do {
                    let model = try parser.parse(object: json as AnyObject)
                    
                    self.dump("Got valid models back")
                    completion(Response(value: model, headers: urlResponse.allHeaderFields))
                } catch let error as ResponseError {
                    completion(Response.failure(error))
                } catch {
                    fatalError("Unhandled error : \(error)")
                }
            } else {
                let errorCode = ResponseError.Code(rawValue: urlResponse.statusCode) ?? .unhandled
                if errorCode == .unhandled {
                    self.dump("Unhandled HTTP response code : \(urlResponse.statusCode)")
                }
                
                completion(Response(errorCode: errorCode))
            }
        }).resume()
    }
    
    // MARK: - Private methods
    private func dump(_ text: String) {
        #if DEBUG
            print("[RESTClient] \(text)")
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
            for (header, value) in response.allHeaderFields {
                dump("\t\t\t\t\(header): \(value)")
            }
        }
    }
}
