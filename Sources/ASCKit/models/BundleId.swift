//
//  BundleId.swift
//  ASCKit
//
//  Created by Stefan Herold on 10.02.21.
//

import Foundation

public struct BundleId {
    public var type: String
    public var id: String
    public var attributes: Attributes
    public var relationships: Relationships
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

public extension Array where Element == BundleId {

    func out(_ attribute: String?) {
        switch attribute {
        case "attributes": out(\.attributes, attribute: attribute)
        case "identifier": out(\.attributes.identifier, attribute: attribute)
        case "name": out(\.attributes.name, attribute: attribute)
        case "platform": out(\.attributes.platform, attribute: attribute)
        case "seedid": out(\.attributes.seedId, attribute: attribute)
        default: out()
        }
    }
}

extension BundleId: IdentifiableModel {

    public var name: String {
        attributes.name
    }
}
