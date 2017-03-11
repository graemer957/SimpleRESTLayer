//
//  JSONModel.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 11/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import Foundation


public protocol JSONModel {
    
    associatedtype ParsedModel
    func parse(object: AnyObject) throws -> ParsedModel
    
}
