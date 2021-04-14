//
//  ApiKey.swift
//  ASCKit
//
//  Created by Stefan Herold on 17.11.20.
//

import Foundation

public struct ApiKey: IdentifiableModel {
    public var id: String
    public var name: String
    public var source: JSONWebToken.PrivateKeySource
    public var issuerId: String
    public var isActive: Bool

    public init(id: String, name: String, source: JSONWebToken.PrivateKeySource, issuerId: String, isActive: Bool = false) {
        self.id = id
        self.name = name
        self.source = source
        self.issuerId = issuerId
        self.isActive = isActive
    }
}
