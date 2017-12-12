//
//  FormResponse.swift
//  Demo
//
//  Created by Graeme Read on 08/12/2017.
//  Copyright © 2017 Optimised Labs Ltd. All rights reserved.
//

import Foundation

struct FormResponse: Codable {
    let parameters: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case parameters = "form"
    }
}
