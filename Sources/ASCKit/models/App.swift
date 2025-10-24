//
//  App.swift
//  ASCKit
//
//  Created by Stefan Herold on 18.06.20.
//

import Foundation

public struct App: IdentifiableModel {
    public var id: String
    public var type: String
    public var attributes: Attributes
    public var relationships: Relationships

    public var name: String { attributes.name }
}

public extension App {

    struct Attributes: Model {
        public var name: String
        public var bundleId: String
        public var sku: String
        public var primaryLocale: String
    }

    struct Relationships: Model {
        var betaGroups: Relation
        var preReleaseVersions: Relation
        var betaAppLocalizations: Relation
        var builds: Relation
        var betaLicenseAgreement: Relation
        var betaAppReviewDetail: Relation
    }

    enum FilterKey: String, Model {
        case bundleId
        case id
        case name
        case sku
        case appStoreVersions
        /// Possible values: IOS, MAC_OS, TV_OS
        case appStoreVersionsPlatform = "appStoreVersions.platform"
        /// Possible values: DEVELOPER_REMOVED_FROM_SALE, DEVELOPER_REJECTED, IN_REVIEW, INVALID_BINARY,
        /// METADATA_REJECTED, PENDING_APPLE_RELEASE, PENDING_CONTRACT, PENDING_DEVELOPER_RELEASE,
        /// PREPARE_FOR_SUBMISSION, PREORDER_READY_FOR_SALE, PROCESSING_FOR_APP_STORE, READY_FOR_SALE, REJECTED,
        /// REMOVED_FROM_SALE, WAITING_FOR_EXPORT_COMPLIANCE, WAITING_FOR_REVIEW, REPLACED_WITH_NEW_VERSION
        case appStoreVersionsAppStoreState = "appStoreVersions.appStoreState"
    }
}
