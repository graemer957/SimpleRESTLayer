//
//  Helpers.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 13/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation


/// Attempt to serialise AnyObject into JSON for the purposes of debugging
public func JSONString(from object: AnyObject) -> String {
    if let data = try? JSONSerialization.data(withJSONObject: object, options: []),
        let string = String(data: data, encoding: .utf8)
    {
        return string
    }
    
    return "Unable to convert JSON"
}
