//
//  Group.swift
//  ASCKit
//
//  Created by Stefan Herold on 26.05.20.
//

import Foundation

public struct Group: Codable, Hashable, Equatable  {
    public var type: String
    public var id: String
    public var attributes: Attributes
    public var relationships: Relationships
}

public extension Group {

    struct Attributes: Codable, Hashable, Equatable {
        public var name: String
    }

    struct Relationships: Codable, Hashable, Equatable {
        var app: Relation
        var builds: Relation
        var betaTesters: Relation
    }

    enum FilterKey: String, Codable {
        case apps
        case builds
        case id
        case isInternalGroup
        case name
        case publicLinkEnabled
        case publicLink
    }
}

public extension Array where Element == Group {

    func out(_ attribute: String?) {
        switch attribute {
        case "name": out(\.attributes.name)
        case "attributes": out(\.attributes)
        default: out()
        }
    }
}

extension Group: Model {
    public var name: String { attributes.name }
}
