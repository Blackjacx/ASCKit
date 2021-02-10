//
//  BetaTester.swift
//  ASCKit
//
//  Created by Stefan Herold on 16.07.20.
//

import Foundation

public struct BetaTester {
    public var type: String
    public var id: String
    public var attributes: Attributes
    public var relationships: Relationships
}

public extension BetaTester {

    enum InviteType: String, CaseIterable, Model {
        case email = "EMAIL"
        case publicLink = "PUBLIC_LINK"
    }

    struct Attributes: Model {
        public var firstName: String? = ""
        public var lastName: String? = ""
        public var email: String? = ""
        public var inviteType: InviteType
    }

    struct Relationships: Codable, Hashable, Equatable {
        var apps: Relation
        var betaGroups: Relation
        var builds: Relation
    }

    enum FilterKey: String, Model {
        case apps
        case betaGroups
        case builds
        case email
        case firstName
        /// Possible values: EMAIL, PUBLIC_LINK
        case inviteType
        case lastName
    }
}

public extension Array where Element == BetaTester {

    func out(_ attribute: String?) {
        switch attribute {
        case "name": out(\.name, attribute: attribute)
        case "attributes": out(\.attributes, attribute: attribute)
        case "firstName": out(\.attributes.firstName, attribute: attribute)
        case "lastName": out(\.attributes.lastName, attribute: attribute)
        case "email": out(\.attributes.email, attribute: attribute)
        default: out()
        }
    }
}

extension BetaTester: IdentifiableModel {

    public var name: String {
        [attributes.firstName, attributes.lastName].compactMap { $0 }.joined(separator: " ")
    }
}
