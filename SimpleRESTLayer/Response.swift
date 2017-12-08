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
    
    case success(model: T, headers: Headers?)
    case failure(ResponseError)
}

extension Response {
    init(model: T, headers: Headers? = nil) {
        self = .success(model: model, headers: headers)
    }
    
    init(errorCode: ResponseError.Code, message: String? = nil) {
        self = .failure(ResponseError(code: errorCode, message: message))
    }
}
