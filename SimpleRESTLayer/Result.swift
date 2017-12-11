//
//  Result.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation

public enum Result<T> {
    public typealias Headers = [AnyHashable: Any]
    
    case success(model: T, headers: Headers?)
    case failure(Error)
}

extension Result {
    init(_ model: T, headers: Headers? = nil) {
        self = .success(model: model, headers: headers)
    }
}
