//
//  AscEndpoint.swift
//  ASCKit
//
//  Created by Stefan Herold on 27.05.20.
//

import Foundation
import Engine

private var apiKey: ApiKey?
private let apiVersion: String = "v1"
private let baseUrlPath = "api.appstoreconnect.apple.com"

enum AscGenericEndpoint<M: Model> {
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

    var host: String {
        baseUrlPath
    }

    var port: Int? {
        nil
    }

    var path: String {
        switch self {
        /// For the URL path the following algorithm is used:
        /// - (Singular) Model name -> lowercase 1st letter -> append an 's' to make it plural
        /// This yields the path name of the model and saves  lot of typing.
        case .list(let type, _, _): return "/\(apiVersion)/\(String(describing: type.self).lowercasedFirst())s"
        case .delete(let type, let id): return "/\(apiVersion)/\(String(describing: type.self).lowercasedFirst())s/\(id)"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .delete: return []
        case let .list(_, filters, limit): return queryItems(from: filters, limit: limit)
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list: return .get
        case .delete: return .delete
        }
    }

    var headers: [String : String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json",
        ]

        if shouldAuthorize {
            do {
                let token = try determineToken()
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

    func jsonDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try Json.decoder.decode(DataWrapper<T>.self, from: data).data
    }
}

extension AscEndpoint: Endpoint {

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
                let token = try determineToken()
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

    func determineToken() throws -> String {

        if apiKey == nil {
            let op = ApiKeysOperation(.list)
            op.executeSync()
            let apiKeys = try op.result.get()

            switch apiKeys.count {
            case 0: throw AscError.noApiKeysSpecified
            case 1: apiKey = apiKeys[0]
            default:
                print("Please choose one of the registered API keys:")
                var options = apiKeys.enumerated().map {
                    "\t \($0 + 1). \($1.name) (\($1.keyId))"
                }
                options[0].append(" <- default")
                options.forEach { print($0) }

                guard let index = readLine().map({(Int($0) ?? 1) - 1}), (0..<apiKeys.count).contains(index) else {
                    throw AscError.invalidInput("Please enter the specified number of the key.")
                }
                apiKey = apiKeys[index]
            }
        }
        return try JSONWebToken.create(keyFile: apiKey!.path, kid: apiKey!.keyId, iss: apiKey!.issuerId)
    }
}
