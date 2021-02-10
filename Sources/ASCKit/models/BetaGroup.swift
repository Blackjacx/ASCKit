//
//  BetaGroup.swift
//  ASCKit
//
//  Created by Stefan Herold on 26.05.20.
//

import Foundation

public struct BetaGroup: IdentifiableModel  {
    public var id: String
    public var type: String
    public var attributes: Attributes
    public var relationships: Relationships
    
    public var name: String { attributes.name }
}

public extension BetaGroup {

    struct Attributes: Model {
        public var name: String
    }

    struct Relationships: Model {
        var app: Relation
        var builds: Relation
        var betaTesters: Relation
    }

    enum FilterKey: String, Model {
        case apps
        case builds
        case id
        case isInternalGroup
        case name
        case publicLinkEnabled
        case publicLink
    }
}

public extension Array where Element == BetaGroup {

    func out(_ attribute: String?) {
        switch attribute {
        case "name": out(\.attributes.name)
        case "attributes": out(\.attributes)
        default: out()
        }
    }
}
