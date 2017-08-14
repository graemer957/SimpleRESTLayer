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
    fileprivate let configuration: URLSessionConfiguration
    
    
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
        
        if let headers = configuration.httpAdditionalHeaders as? [String: String] {
            dprint("Configuration headers : \(headers)")
        }
        
        if let timeout = timeout {
            configuration.timeoutIntervalForRequest = timeout
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
            // TODO: This should only be created once!?
            let session = URLSession(configuration: self.configuration)
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                #if DEBUG
                    self.dumpRequest(request)
                    if let response = response as? HTTPURLResponse {
                        self.dumpResponse(response)
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
                        self.dprint("Unhandled NSURLSession Error: \(error.localizedDescription): \(error.userInfo)")
                        
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
                        
                        self.dprint("Got valid models back")
                        completion(Response(value: model, headers: urlResponse.allHeaderFields))
                    } catch let error as ResponseError {
                        completion(Response.failure(error))
                    } catch {
                        fatalError("Unhandled error : \(error)")
                    }
                } else {
                    let errorCode = ResponseError.Code(rawValue: urlResponse.statusCode) ?? .unhandled
                    if errorCode == .unhandled {
                        self.dprint("Unhandled HTTP response code : \(urlResponse.statusCode)")
                    }
                    
                    completion(Response(errorCode: errorCode))
                }
            })
            task.resume()
        }
    }
    
    
    // MARK: - Private methods
    fileprivate func dprint(_ text: String) {
        #if DEBUG
            print("[Network] \(text)")
        #endif
    }
    
    fileprivate func dumpRequest(_ request: URLRequest) {
        print("")
        dprint("Request URL:\t\(request.httpMethod!) \(request.url!.absoluteString)")
        
        if let allHTTPHeaderFields = request.allHTTPHeaderFields, allHTTPHeaderFields.count > 0 {
            dprint("Headers:\t\t\(allHTTPHeaderFields)")
        }
        
        if let data = request.httpBody {
            dprint("Body:\t\t\t\(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
        }
        
        print("")
    }
    
    fileprivate func dumpResponse(_ response: HTTPURLResponse) {
        if let responseURL = response.url?.absoluteString {
            dprint("Response URL:\t\(responseURL)")
        }
        dprint("Status:\t\t\(response.statusCode)")
        
        if response.allHeaderFields.count > 0 {
            dprint("Headers:")
            for (header, value) in response.allHeaderFields {
                dprint("\t\t\t\t\(header): \(value)")
            }
        }
        
        print("")
    }
    
}
