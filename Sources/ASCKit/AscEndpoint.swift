//
//  AscEndpoint.swift
//  ASCKit
//
//  Created by Stefan Herold on 27.05.20.
//

import Foundation
import Engine

private let apiVersion: String = "v1"
private let baseUrlPath = "api.appstoreconnect.apple.com"

enum AscGenericEndpoint<M: Model> {
    case url(_ url: URL, type: M.Type)
    case list(type: M.Type, filters: [Filter], limit: UInt?)
    case delete(type: M.Type, id: String)
}

enum AscEndpoint {
    case read(url: URL, filters: [Filter], limit: UInt)

    case listAppStoreVersions(appId: String, filters: [Filter], limit: UInt?)

    case inviteBetaTester(testerId: String, appId: String)
    case addBetaTester(email: String, firstName: String, lastName: String, groupId: String)

    case registerBundleId(attributes: BundleId.Attributes)

    case expireBuild(_ build: Build)
}

extension AscGenericEndpoint: Endpoint {

    var url: URL? {
        switch self {
        case .url(let url, _): return url
        default: return nil
        }
    }

    var host: String {
        baseUrlPath
    }

    var port: Int? {
        nil
    }

    var path: String {
        let type: M.Type
        var pathSuffix: String?

        switch self {
        case .url: return ""
        case .list(let t, _, _): type = t
        case .delete(let t, let id): type = t; pathSuffix = id
        }

        /// For the URL path the following algorithm is used:
        /// - (Singular) Model name -> lowercase 1st letter -> append an 's' to pluralize it
        /// This yields the path name of the model and saves  lot of typing.
        let base = "/\(apiVersion)/\(String(describing: type.self).lowercasedFirst())s"

        guard let suffix = pathSuffix else {
            return base
        }
        return base.appendPathComponent(suffix)
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .url: return []
        case let .list(_, filters, limit): return queryItems(from: filters, limit: limit)
        case .delete: return []
        }
    }

    var method: HTTPMethod {
        switch self {
        case .url, .list: return .get
        case .delete: return .delete
        }
    }

    var headers: [String : String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json",
        ]

        if shouldAuthorize {
            do {
                let token = try ApiKeysOperation.createAccessToken()
                headers["Authorization"] = "Bearer \(token)"
            } catch {
                print(error)
            }
        }
        return headers
    }

    var parameters: [String : Any]? {
        nil
    }

    var shouldAuthorize: Bool {
        true
    }

    func jsonDecode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        switch self {
        case .url, .list:
            let directResult = Result { try Json.decoder.decode(T.self, from: data) }

            guard (try? directResult.get()) != nil else {
                // Decode data-wrapped result, e.g. [BetaTester]
                return try Json.decoder.decode(DataWrapper<T>.self, from: data).data
            }

            // Extract data wrapped model, e.g. PageableModel<BetaTester>, or throw the error
            return try directResult.get()

        case .delete:
            // Decode result directly since we always use EmptyResponse here
            return try Json.decoder.decode(T.self, from: data)
        }
    }
}

extension AscEndpoint: Endpoint {

    /// Used o specify the id of an already registered key to use
    public static var apiKeyId: String?

    var url: URL? {
        return nil
    }

    var host: String {
        baseUrlPath
    }

    var port: Int? {
        nil
    }

    var path: String {
        switch self {
        case .read(let url, _, _): return url.path
        case .listAppStoreVersions(let appId, _, _): return "/\(apiVersion)/apps/\(appId)/appStoreVersions"

        case .inviteBetaTester: return "/\(apiVersion)/betaTesterInvitations"
        case .addBetaTester: return "/\(apiVersion)/betaTesters"

        case .registerBundleId: return "/\(apiVersion)/bundleIds"

        case .expireBuild(let build): return "/\(apiVersion)/builds/\(build.id)"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .read(_, filters, limit):
            return queryItems(from: filters, limit: limit)

        case let .listAppStoreVersions(_, filters, limit):
            return queryItems(from: filters, limit: limit)

        case .inviteBetaTester, .addBetaTester, .registerBundleId, .expireBuild:
            return []
        }
    }

    var method: HTTPMethod {
        switch self {
        case .read, .listAppStoreVersions:
            return .get
        case .addBetaTester, .inviteBetaTester, .registerBundleId:
            return .post
        case .expireBuild:
            return .patch
        }
    }

    var shouldAuthorize: Bool {
        true
    }

    var headers: [String : String]? {

        var headers: [String: String] = [
            "Content-Type": "application/json",
        ]

        if shouldAuthorize {
            do {
                let token = try ApiKeysOperation.createAccessToken()
                headers["Authorization"] = "Bearer \(token)"
            } catch {
                print(error)
            }
        }
        return headers
    }

    var parameters: [String : Any]? {
        switch self {
        case .read, .listAppStoreVersions:
            return nil
        case let .addBetaTester(email, firstName, lastName, groupId):
            return [
                "data": [
                    "type": "betaTesters",
                    "attributes": [
                        "email": email,
                        "firstName": firstName,
                        "lastName": lastName,
                    ],
                    "relationships": [
                        "betaGroups": [
                            "data": [
                                [ "type": "betaGroups", "id": groupId ]
                            ]
                        ]
                    ]
                ]
            ]
        case let .inviteBetaTester(testerId, appId):
            return [
                "data": [
                    "type": "betaTesterInvitations",
                    "relationships": [
                        "app": [
                            "data": [
                                "type": "apps",
                                "id": appId,
                            ]
                        ],
                        "betaTester": [
                            "data": [
                                "type": "betaTesters",
                                "id": testerId,
                            ]
                        ]
                    ]
                ]
            ]
        case let .registerBundleId(bundleIdAttributes):
            var attributes: [String: Any] = [
                "identifier": bundleIdAttributes.identifier,
                "name": bundleIdAttributes.name,
                "platform": bundleIdAttributes.platform.rawValue
            ]

            if let seedId = bundleIdAttributes.seedId {
                attributes["seedId"] = seedId
            }

            return [
                "data": [
                    "type": "bundleIds",
                    "attributes": attributes
                ]
            ]
        case let .expireBuild(build):
            let attributes: [String: Any] = [
                "expired": true
            ]

            return [
                "data": [
                    "id": "\(build.id)",
                    "type": "builds",
                    "attributes": attributes
                ]
            ]
        }
    }

    func jsonDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try Json.decoder.decode(DataWrapper<T>.self, from: data).data
    }
}

extension Endpoint {

    func queryItems(from filters: [Filter], limit: UInt?) -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        items += filters.map { URLQueryItem(name: "filter[\($0.key)]", value: $0.value) }
        items += [URLQueryItem(name: "limit", value: "\(limit ?? Constants.maxPageSize)")]
        return items
    }
}
