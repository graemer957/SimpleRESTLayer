//
//  Result.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Optimised Labs Ltd. All rights reserved.
//

import Foundation

public enum Result<Model: Decodable> {
    /// Successful results have a Response and Model
    case success(Response, Model)
    
    /// Failure results contain an Error
    case failure(Error)
    
    // Initialise a result from a function that throws
    public init(_ response: Response, capturing: () throws -> Model) {
        do {
            self = .success(response, try capturing())
        } catch {
            self = .failure(error)
        }
    }
    
    /// Adapter method to convert Result into Response/Model or throw
    public func unwrap() throws -> (Response, Model) {
        switch self {
        case let .success(response, model):
            return (response, model)
        case let .failure(error):
            throw error
        }
    }
    
    /// Transform result to a new value, potentially of a new type
    public func map<U>(_ transform: (Model) throws -> U) -> Result<U> {
        switch self {
        case let .success(response, model):
            return Result<U>(response) { try transform(model) }
        case let .failure(error):
            return .failure(error)
        }
    }
    
    /// Generate another result of potentially a new type
    public func flapMap<U>(_ transform: (Response, Model) -> Result<U>) -> Result<U> {
        switch self {
        case let .success(response, model):
            return transform(response, model)
        case let .failure(error):
            return .failure(error)
        }
    }
}
