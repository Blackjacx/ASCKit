//
//  ApiKey.swift
//  ASCKit
//
//  Created by Stefan Herold on 17.11.20.
//

import Engine
import Foundation

public struct ApiKey: IdentifiableModel {
    public var id: String
    public var name: String
    public var source: JWT.KeySource
    public var issuerId: String
    public var isActive: Bool

    public init(id: String, name: String, source: JWT.KeySource, issuerId: String, isActive: Bool = false) {
        self.id = id
        self.name = name
        self.source = source
        self.issuerId = issuerId
        self.isActive = isActive
    }
}
