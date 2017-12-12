//
//  Result.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Optimised Labs Ltd. All rights reserved.
//

import Foundation

public enum Result<Model> {
    case success(Response, Model)
    case failure(Error)
}
