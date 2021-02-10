//
//  ApiKey.swift
//  ASCKit
//
//  Created by Stefan Herold on 17.11.20.
//

import Foundation

public struct ApiKey {
    public var id: String = UUID().uuidString
    public var name: String
    public var path: String
    public var keyId: String
    public var issuerId: String

    public init(name: String, path: String, keyId: String, issuerId: String) {
        self.name = name
        self.path = path
        self.keyId = keyId
        self.issuerId = issuerId
    }
}

extension ApiKey: IdentifiableModel {}
