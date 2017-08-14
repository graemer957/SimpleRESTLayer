//
//  RESTClient.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation


public final class RESTClient {
    
    // MARK: - Properties
    private let configuration: URLSessionConfiguration
    private let session: URLSession
    
    
    // MARK: - Initialiser
    public init(appName: String? = nil, headers: [AnyHashable : Any]? = nil, timeout: TimeInterval? = nil) {
        self.configuration = URLSessionConfiguration.ephemeral
        self.configuration.httpAdditionalHeaders = [
            "Accept": "application/json;charset=utf-8",
            "Accept-Encoding": "gzip"
        ]
        
        if let infoDictionary = Bundle.main.infoDictionary, let name = infoDictionary["CFBundleName"] as? String, let version = infoDictionary["CFBundleShortVersionString"] as? String, let build = infoDictionary["CFBundleVersion"] as? String
        {
            let userAgent = "\(appName ?? name) v\(version) (\(build))"
            self.configuration.httpAdditionalHeaders?["User-Agent"] = userAgent
        }
        
        if let headers = headers {
            for (field, value) in headers {
                self.configuration.httpAdditionalHeaders![field] = value
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
    public func execute<T: ResponseParser>(_ request: URLRequest, parser: T, handler: @escaping (Response<T.ParsedModel>) -> Void) {
        // Ensure all our responses are back on the main thread
        let completion = { (response: Response<T.ParsedModel>) in
            DispatchQueue.main.async {
                handler(response)
            }
        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
                #if DEBUG
                    self.dump(request: request)
                    if let response = response as? HTTPURLResponse {
                        self.dump(response: response)
                    }
                #endif
                
                if let error = error as NSError? {
                    if error.domain == NSURLErrorDomain {
                        switch error.code {
                        case NSURLErrorNotConnectedToInternet: fallthrough
                        case NSURLErrorTimedOut: fallthrough
                        case NSURLErrorCannotConnectToHost:
                            completion(Response(errorCode: .connectionError, message: "Check internet connection and try again."))
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
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) else
                    {
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
            })
            task.resume()
        }
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
        
        if let data = request.httpBody {
            dump("Body:\t\t\t\(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
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
