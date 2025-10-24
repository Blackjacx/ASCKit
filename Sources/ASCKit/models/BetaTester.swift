//
//  BetaTester.swift
//  ASCKit
//
//  Created by Stefan Herold on 16.07.20.
//

import Foundation

public struct BetaTester: IdentifiableModel {
    public var id: String
    public var type: String
    public var attributes: Attributes
    public var relationships: Relationships

    public var name: String {
        var comps = PersonNameComponents()
        comps.givenName = attributes.firstName
        comps.familyName = attributes.lastName
        return PersonNameComponentsFormatter.localizedString(from: comps, style: .default, options: [])
    }
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
