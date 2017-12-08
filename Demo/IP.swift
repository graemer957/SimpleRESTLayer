//
//  IP.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 14/08/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation
import SimpleRESTLayer

// swiftlint:disable type_name
struct IP {
    let address: String
}
// swiftlint:enable type_name

struct IPParser: ResponseParser {
    // MARK: - ResponseParser
    typealias ParsedModel = IP
    
    func parse(object: AnyObject) throws -> IP {
        if let dictionary = object as? [String: Any],
        let address = dictionary["origin"] as? String {
            return IP(address: address)
        }
        
        throw ResponseError(code: .invalidJSON, message: "ip: \(JSONString(from: object))")
    }
}
