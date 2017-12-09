//
//  JSONResponse.swift
//  Demo
//
//  Created by Graeme Read on 08/12/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation

struct JSONResponse: Codable {
    let string: String
    
    enum CodingKeys: String, CodingKey {
        case string = "data"
    }
}
