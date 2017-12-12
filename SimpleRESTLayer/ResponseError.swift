//
//  ResponseError.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation

public enum ResponseError: Error {
    /// Response is not an HTTP response
    case invalid
    
    /// HTTP status code was not defined in Response.Status, please raise a PR.
    case undefinedStatus(Int)
    
    /// Server returned an unsuccessful HTTP response
    case unsuccessful(Response)
}
