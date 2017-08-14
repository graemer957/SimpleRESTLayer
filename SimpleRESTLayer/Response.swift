//
//  Response.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation


public enum Response<T> {
    public typealias Headers = [AnyHashable: Any]
    
    case success(T, Headers?)
    case failure(ResponseError)
    
    init(value: T, headers: Headers? = nil) {
        self = .success(value, headers)
    }
    
    init(errorCode: ResponseError.Code, message: String? = nil) {
        self = .failure(ResponseError(code: errorCode, message: message))
    }
}
