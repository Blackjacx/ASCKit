//
//  AppInfo.swift
//  ASCKit
//
//  Created by Stefan Herold on 23.10.25.
//

import Foundation

public struct AppInfo: IdentifiableModel {
    public var id: String
    public var type: String
    public var attributes: Attributes

    public var name: String {
        id
    }
}

public struct AppInfoResponse: IdentifiableModel {
    let data: [AppInfo]
    let included: [IncludedResource]?

    public var id: String = UUID().uuidString
    public var name: String {
        id
    }

    // MARK: - Sub Types

    public enum IncludedResource: Model {
        case ageRatingDeclaration(_ value: AgeRatingDeclaration)

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            // Checking of the JSON:API `type` field
            switch type {
            case "ageRatingDeclarations":
                let value = try AgeRatingDeclaration(from: decoder)
                self = .ageRatingDeclaration(value)
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Unknown included type: \(type)"
                )
            }
        }

        public func encode(to encoder: any Encoder) throws {
            switch self {
            case .ageRatingDeclaration(let value):
                try value.encode(to: encoder)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case type
        }

        public enum Types: String {
            case ageRatingDeclaration
        }
    }
}

public extension AppInfo {

    struct Attributes: Model {
        public var state: AppStoreVersion.State
    }
}
