//
//  APIController.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 14/08/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation
import SimpleRESTLayer


final class APIController {
    // MARK: - Properties
    let client = RESTClient()
    
    // MARK: - Structs
    fileprivate struct URL {
        private static let baseAddress = "https://httpbin.org/"
        
        /// Returns the IP that the request came in from
        static let IP = baseAddress + "ip"
    }
    
    // MARK: - Instance methods
    func getIP(completion: @escaping (Response<IP>) -> Void) {
        let request = Request.with(
            method: .get,
            address: URL.IP
        )
        client.execute(request: request, parser: IPParser(), handler: completion)
    }
}
