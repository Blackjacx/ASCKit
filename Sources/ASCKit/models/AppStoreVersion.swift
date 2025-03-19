//
//  AppStoreVersion.swift
//  ASCKit
//
//  Created by Stefan Herold on 07.09.20.
//

import Foundation

public struct AppStoreVersion: IdentifiableModel {
    public var id: String
    public var type: String
    public var attributes: Attributes
    public var relationships: Relationships

    public var name: String { "" }
}

public extension AppStoreVersion {

    enum State: String, Model {
        case accepted = "ACCEPTED"
        case developerRejected = "DEVELOPER_REJECTED"
        case developerRemovedFromSale = "DEVELOPER_REMOVED_FROM_SALE"
        case inReview = "IN_REVIEW"
        case invalidBinary = "INVALID_BINARY"
        case metadataRejected = "METADATA_REJECTED"
        case pendingAppleRelease = "PENDING_APPLE_RELEASE"
        case pendingContract = "PENDING_CONTRACT"
        case pendingDeveloperRelease = "PENDING_DEVELOPER_RELEASE"
        case preorderReadyForSale = "PREORDER_READY_FOR_SALE"
        case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
        case processingForAppStore = "PROCESSING_FOR_APP_STORE"
        case processingForDistribution = "PROCESSING_FOR_DISTRIBUTION"
        case readyForDistribution = "READY_FOR_DISTRIBUTION"
        case readyForReview = "READY_FOR_REVIEW"
        case readyForSale = "READY_FOR_SALE"
        case rejected = "REJECTED"
        case removedFromSale = "REMOVED_FROM_SALE"
        case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
        case waitingForExportCompliance = "WAITING_FOR_EXPORT_COMPLIANCE"
        case waitingForReview = "WAITING_FOR_REVIEW"
    }

    struct Attributes: Model {
        public var platform: String
        public var versionString: String
        public var appStoreState: State
        public var copyright: String? = ""
        public var createdDate: Date
    }

    struct Relationships: Model {
//        var betaGroups: Relation
//        var preReleaseVersions: Relation
//        var betaAppLocalizations: Relation
//        var builds: Relation
//        var betaLicenseAgreement: Relation
//        var betaAppReviewDetail: Relation
    }
}

public extension Array where Element == AppStoreVersion {

    func out(_ attribute: String?) {
        switch attribute {
        case "attributes": out(\.attributes)
        default: out()
        }
    }
}
