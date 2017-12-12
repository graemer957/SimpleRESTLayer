//
//  Data.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 12/12/2017.
//  Copyright © 2017 Optimised Labs Ltd. All rights reserved.
//

import Foundation

extension Data {
    func decode<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder) throws -> T {
        if let data = self as? T {
            return data
        }
        
        return try decoder.decode(type, from: self)
    }
}
