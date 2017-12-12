//
//  IP.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 14/08/2017.
//  Copyright © 2017 Optimised Labs Ltd. All rights reserved.
//

import Foundation

struct IP: Codable {
    let address: String
    
    enum CodingKeys: String, CodingKey {
        case address = "origin"
    }
}
