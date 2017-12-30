//
//  Response.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 11/12/2017.
//  Copyright © 2017 Optimised Labs Ltd. All rights reserved.
//

import Foundation

public struct Response {
    /// Commonly used HTTP status codes
    /// See https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html and https://en.wikipedia.org/wiki/List_of_HTTP_status_codes for coplete list
    public enum Status: Int {
        /// The request has succeeded
        case ok = 200
        
        /// The request has been fulfilled and resulted in a new resource being created
        case created = 201
        
        /// The request has been accepted for processing, but the processing has not been completed
        case accepted = 202
        
        /// The server has fulfilled the request but does not need to return an entity-body, and might want to return updated metainformation
        case noContent = 204
        
        /// The server has fulfilled the partial GET request for the resource
        case partialContent = 206
        
        /// The resource has not been modified
        case notModified = 304
        
        /// The request could not be understood by the server due to malformed syntax
        case badRequest = 400
        
        /// The request requires user authentication
        case unauthorised = 401
        
        /// The server understood the request, but is refusing to fulfill it
        case forbidden = 403
        
        /// The server has not found anything matching the Request-URI
        case notFound = 404
        
        /// The method specified in the Request-Line is not allowed for the resource identified by the Request-URI
        case methodNotAllowed = 405
        
        /// The resource identified by the request is only capable of generating response entities which have content characteristics not acceptable according to the accept headers sent in the request.
        case notAcceptable = 406
        
        /// The client did not produce a request within the time that the server was prepared to wait
        case requestTimeout = 408
        
        /// The requested resource is no longer available at the server and no forwarding address is known
        case gone = 410
        
        /// The user has sent too many requests in a given amount of time
        case tooManyRequests = 429
        
        /// The server encountered an unexpected condition which prevented it from fulfilling the request
        case serverError = 500
        
        /// The server does not support the functionality required to fulfill the request
        case notImplemented = 501
        
        /// The server, while acting as a gateway or proxy, received an invalid response from the upstream server it accessed in attempting to fulfill the request
        case badGateway = 502
        
        /// The server is currently unable to handle the request due to a temporary overloading or maintenance of the server
        case serviceUnavailable = 503
        
        /// The server, while acting as a gateway or proxy, did not receive a timely response from the upstream server
        case gatewayTimeout = 504
    }

    let status: Status
    let headers: [AnyHashable: Any]
    
    init(_ status: Status, headers: [AnyHashable: Any]) {
        self.status = status
        self.headers = headers
    }
}

extension Response: CustomStringConvertible {
    public var description: String {
        return "status: .\(status)"
    }
}

extension Response: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "status: .\(status), headers: \(headers.map { "\($0): \($1)" })"
    }
}

extension Response.Status {
    func isSuccessful() -> Bool {
        return [.ok, .created, .accepted, .noContent, .partialContent].contains(self)
    }
}
