//
//  Build.swift
//  ASCKit
//
//  Created by Stefan Herold on 18.06.20.
//

import Foundation

public struct Build: IdentifiableModel {
    public var id: String
    public var type: String
    public var attributes: Attributes
    public var relationships: Relationships

    public var name: String { attributes.version }
}

public extension Build {

    enum ProcessingState: String, Model {
        case processing = "PROCESSING"
        case failed = "FAILED"
        case invalid = "INVALID"
        case valid = "VALID"
    }

    struct Attributes: Model {
        public var expired: Bool
        public var minOsVersion: String
        public var processingState: ProcessingState
        public var version: String
        public var usesNonExemptEncryption: Bool?
        public var uploadedDate: Date
        public var expirationDate: Date
    }

    struct Relationships: Model {
        var app: Relation
        var appEncryptionDeclaration: Relation
        var individualTesters: Relation
        var preReleaseVersion: Relation
        var betaBuildLocalizations: Relation
        var buildBetaDetail: Relation
        var betaAppReviewSubmission: Relation
        var appStoreVersion: Relation
        var icons: Relation
    }

    enum FilterKey: String, Model {
        case app
        case expired
        case id
        case preReleaseVersion
        /// Possible values: PROCESSING, FAILED, INVALID, VALID
        case processingState
        case version
        case usesNonExemptEncryption
        case preReleaseVersionVersion = "preReleaseVersion.version"
        case betaGroups
        /// Possible values: WAITING_FOR_REVIEW, IN_REVIEW, REJECTED, APPROVED
        case betaReviewState = "betaAppReviewSubmission.betaReviewState"
        case appStoreVersion
        case preReleaseVersionPlatform = "preReleaseVersion.platform"
    }
}

public extension Array where Element == Build {

    func out(_ attribute: String?) {
        switch attribute {
        case "attributes": out(\.attributes)
        case "expired": out(\.attributes.expired)
        case "minOsVersion": out(\.attributes.minOsVersion)
        case "processingState": out(\.attributes.processingState)
        case "version": out(\.attributes.version)
        case "usesNonExemptEncryption": out(\.attributes.usesNonExemptEncryption)
        case "uploadedDate": out(\.attributes.uploadedDate)
        case "expirationDate": out(\.attributes.expirationDate)
        default: out()
        }
    }
}
