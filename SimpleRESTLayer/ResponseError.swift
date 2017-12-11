//
//  ResponseError.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation

public enum ResponseError: Error {
    /// HTTP status code was not defined in Response.Status, please raise a PR.
    case undefinedStatus(Int)
    
    /// Server returned unsuccessful HTTP response
    case unsuccessful(Response)
    
    /// Response did not contain any data to turn into model
    case noData
}

public struct ResponseErrorOld: Error {
    // MARK: - Enums
    public enum Code: Int {
        /// Unhandled response
        case unhandled = 0
        
        /// The API request encountered a connection error
        case connectionError = 1
        
        /// The response from the API was probably not valid JSON
        case invalidJSON = 2
        
        /// The response from the API could not be parsed into a model
        case parseError = 3
        
        /// Response doesn't looks like HTTP response!
        case invalidHTTPResponse = 4
        
        /// Response doesn't contain any data to turn into model!
        case noData = 5
        
        /// Response has not been modified since last request
        case notModified = 304
        
        /// The request was bad
        case badRequest = 400
        
        /// The request was unauthorised
        case unauthorized = 401
        
        /// The request was denied, eg, accessing resource on different estate
        case forbidden = 403
        
        /// The request was to an invalid endpoint
        case notFound = 404
        
        /// The API request encountered a server error
        case serverError = 500
    }
    
    // MARK: - Properties
    public let code: Code
    public let message: String?
}

extension ResponseErrorOld {
    init(_ code: Code) {
        self.code = code
        self.message = nil
    }
}
