//
//  Headers.swift
//  Demo
//
//  Created by Graeme Read on 08/12/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation

struct Headers: Codable {
    let dictionary: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case dictionary = "headers"
    }
}
