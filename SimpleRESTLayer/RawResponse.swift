//
//  RawResponse.swift
//  SimpleRESTLayer
//
//  Created by Graeme Read on 09/12/2017.
//

import Foundation

public struct RawResponse: Codable {
    // MARK: - Properties
    public let data: Data?
    
    // MARK: - Methods
    public static func from(_ data: Data?) -> Data {
        // swiftlint:disable force_try
        return try! JSONEncoder().encode(RawResponse(data: data))
        // swiftlint:enable force_try
    }
}
