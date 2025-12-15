//
//  BundleId.swift
//  ASCKit
//
//  Created by Stefan Herold on 10.02.21.
//

import Foundation

public struct BundleId: IdentifiableModel {
    public var id: String
    public var type: String
    public var attributes: Attributes
    public var relationships: Relationships

    public var name: String { attributes.name }
}

public extension BundleId {

    enum Platform: String, CaseIterable, Model {
        case ios = "IOS"
        case macos = "MAC_OS"
        case universal = "UNIVERSAL"
    }

    struct Attributes: Model {
        public var identifier: String
        public var name: String
        public var platform: Platform
        public var seedId: String?
    }

    struct Relationships: Model {
        var profiles: Relation
        var bundleIdCapabilities: Relation
        var app: Relation?
    }

    enum FilterKey: String, Model {
        case id
        case identifier
        case name
        case platform
        // Possible values: see BundleId.Platform
        case seedId
    }
}
