//
//  Response.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation


public enum Response<T> {
    case success(T)
    case failure(ResponseError)
    
    public init(value: T) {
        self = .success(value)
    }
    
    public init(errorCode: ResponseError.Code, message: String? = nil) {
        self = .failure(ResponseError(code: errorCode, message: message))
    }
}
