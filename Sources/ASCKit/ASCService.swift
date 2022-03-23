//
//  Network+Requests.swift
//  ASCKit
//
//  Created by Stefan Herold on 27.05.20.
//

import Foundation
import Engine

/// The central class to deal with the App Store Connect API. This object must
/// be equally compatible with CLI tools and SwiftUI apps. As an example no
/// code should be printed here what is the typical format of output for CLI
/// tools. Better handle this in the commands CLI tool itself.
public struct ASCService {

    static let network = Network.shared

    /// Collection of registered API keys
    @Defaults("\(ProcessInfo.processId).apiKeys", defaultValue: []) private static var apiKeys: [ApiKey]
    /// For command line applications set to the key ID passed as parameter
    public static var specifiedKeyId: String?

    // MARK: - Generic List

    #warning("Load all pages here when limit == nil")
    /// Async/await function to genrically get pageable models for each model
    /// of the ASC API. Automatically evaluates the previous result or fetches
    /// the first page if nil.
    /// - note: Suitable for both CLI tools and SwiftUI apps
    /// - throws: NetworkError
    public static func list<P: Pageable>(previousPageable: P?,
                                         filters: [Filter] = [],
                                         limit: UInt? = nil) async throws -> P {
        let endpoint: AscGenericEndpoint<P.ModelType>
        if let nextUrl = previousPageable?.nextUrl {
            endpoint = AscGenericEndpoint.url(nextUrl, type: P.ModelType.self)
        } else {
            endpoint = AscGenericEndpoint.list(type: P.ModelType.self, filters: filters, limit: limit)
        }
        return try await network.request(endpoint: endpoint)
    }

    #warning("Load all pages here when limit == nil")
    /// Generic, throwable function to return any list of `IdentifiableModel`s.
    /// - note: Suitable for CLI tools
    public static func list<P: IdentifiableModel>(filters: [Filter] = [], limit: UInt? = nil) async throws -> [P] {
        let loader = PagedItemLoader<P>(filters: filters, limit: limit)
        try await loader.loadMoreIfNeeded()
        return loader.items
    }

    // MARK: Generic Delete

    public static func delete<M: IdentifiableModel>(model: M) async throws -> EmptyResponse {
        let endpoint = AscGenericEndpoint.delete(type: M.self, id: model.id)
        return try await network.request(endpoint: endpoint)
    }

    // MARK: - Creating Access Token

    static func createAccessToken() throws -> String {

        let key: ApiKey

        // Prefer key specified via parameter over activated one
        if let specifiedKeyId = specifiedKeyId {
            guard let specifiedKey = apiKeys.first(where: { $0.id == specifiedKeyId }) else {
                throw AscError.apiKeyNotFound(specifiedKeyId)
            }
            key = specifiedKey
        } else if let activeKey = apiKeys.first(where: { $0.isActive }) {
            // Go with active API key
            key = activeKey
        } else {
            throw AscError.noApiKeysRegistered
        }
        return try JSONWebToken.create(privateKeySource: key.source, kid: key.id, iss: key.issuerId)
    }

    // MARK: API Keys

    public static func listApiKeys() -> [ApiKey] {
        apiKeys
    }

    @discardableResult
    public static func activateApiKey(id: String) throws -> ApiKey {

        guard let matchingKey = Self.apiKeys.first(where: { $0.id == id }) else {
            throw AscError.apiKeyNotFound(id)
        }
        Self.apiKeys.indices.forEach { Self.apiKeys[$0].isActive = Self.apiKeys[$0].id == matchingKey.id }

        guard let matchingActiveKey = Self.apiKeys.first(where: { $0.id == id && $0.isActive }) else {
            throw AscError.apiKeyActivationFailed(matchingKey)
        }
        return matchingActiveKey
    }

    public static func registerApiKey(key: ApiKey) throws -> ApiKey {

        Self.apiKeys.append(key)
        // Activate in case we don't have an active key
        if !hasActiveKey {
            try activateApiKey(id: key.id)
        }
        return key
    }

    public static func deleteApiKey(id: String) throws -> ApiKey {

        guard let matchingKey = Self.apiKeys.first(where: { id == $0.id }) else {
            throw AscError.apiKeyNotFound(id)
        }
        Self.apiKeys = Self.apiKeys.filter { $0.id != id }
        return matchingKey
    }

    private static var hasActiveKey: Bool {
        apiKeys.contains { $0.isActive }
    }

    // MARK: - Apps

    @discardableResult
    public static func listAppStoreVersions(appIds: [String],
                                            filters: [Filter] = [],
                                            limit: UInt? = nil) async throws -> [(app: App, versions: [AppStoreVersion])] {

        typealias ResultType = (app: App, versions: [AppStoreVersion])

        let apps: [App] = try await list()
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map({ $0.id })
        var results: [ResultType] = []
        var errors: [Error] = []

        await withTaskGroup(of: Result<ResultType, Error>.self) { group in

            for id in iterableAppIds {
                let app = apps.first { $0.id == id }!
                let endpoint = AscEndpoint.listAppStoreVersions(appId: id, filters: filters, limit: limit)

                group.addTask {
                    do {
                        return .success((app, versions: try await network.request(endpoint: endpoint)))
                    } catch {
                        return .failure(error)
                    }
                }
            }

            for await result in group {
                switch result {
                case .success(let result): results.append(result)
                case .failure(let error): errors.append(error)
                }
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }

        return results
    }

    // MARK: - Beta Testers

    public static func inviteBetaTester(email: String, appIds: [String]) async throws {

        typealias ResultType = BetaTesterInvitationResponse

        let apps: [App] = try await list()
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map({ $0.id })
        guard iterableAppIds.count > 0 else {
            throw AscError.noDataProvided("app_ids")
        }

        guard let tester: BetaTester = try await list(filters: [Filter(key: BetaTester.FilterKey.email, value: email)]).first else {
            throw AscError.noUserFound(email)
        }

        var results: [ResultType] = []
        var errors: [Error] = []

        await withTaskGroup(of: Result<ResultType, Error>.self) { group in
            for id in iterableAppIds {
                let app = apps.first { id == $0.id }!
                let endpoint = AscEndpoint.inviteBetaTester(testerId: tester.id, appId: id)

                group.addTask {
                    do {
                        let result: ResultType = try await network.request(endpoint: endpoint)
                        print("Invited tester \(tester.name)  (\(tester.id)) to app \(app.name) (\(id))")
                        return .success(result)
                    } catch {
                        print("Failed inviting tester \(tester.name) (\(tester.id)) to app \(app.name) (\(id))")
                        return .failure(error)
                    }
                }
            }

            for await result in group {
                switch result {
                case .success(let result): results.append(result)
                case .failure(let error): errors.append(error)
                }
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
    }

    public static func addBetaTester(email: String, first: String, last: String, groupNames: [String]) async throws {

        typealias ResultType = BetaTester

        // create filters for group names
        let groupFilters: [Filter] = [
            Filter(key: BetaGroup.FilterKey.name, value: groupNames.joined(separator: ","))
        ]
        let betaGroups: [BetaGroup] = try await list(filters: groupFilters)

        var results: [ResultType] = []
        var errors: [Error] = []

        await withTaskGroup(of: Result<ResultType, Error>.self) { group in
            for betaGroup in betaGroups {
                let endpoint = AscEndpoint.addBetaTester(email: email, firstName: first, lastName: last, groupId: betaGroup.id)

                group.addTask {
                    do {
                        let result: BetaTester = try await network.request(endpoint: endpoint)
                        print("Added tester: \(result.name), email: \(email), id: \(result.id) to group: \(betaGroup.name), id: \(betaGroup.id)")
                        return .success(result)
                    } catch {
                        print("Failed adding tester \(email) to group \(betaGroup.name) (\(betaGroup.id))")
                        return .failure(error)
                    }
                }
            }

            for await result in group {
                switch result {
                case .success(let result): results.append(result)
                case .failure(let error): errors.append(error)
                }
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
    }

    public static func deleteBetaTester(email: String) async throws -> BetaTester {

        // Get id's
        let filter = Filter(key: BetaTester.FilterKey.email, value: email)
        let testers: [BetaTester] = try await list(filters: [filter])

        guard let firstTester = testers.first else {
            throw AscError.noUserFound(email)
        }
        _ = try await delete(model: firstTester)
        return firstTester
    }

    // MARK: BundleIDs

    public static func registerBundleId(_ identifier: String,
                                        name: String,
                                        platform: BundleId.Platform,
                                        seedId: String? = nil) async throws -> BundleId {

        let attributes = BundleId.Attributes(identifier: identifier, name: name, platform: platform, seedId: seedId)
        let endpoint = AscEndpoint.registerBundleId(attributes: attributes)
        let bundleId: BundleId = try await network.request(endpoint: endpoint)
        return bundleId
    }

    public static func deleteBundleId(_ id: String) async throws -> BundleId {

        // Get id's
        let filter = Filter(key: BundleId.FilterKey.identifier, value: id)
        let ids: [BundleId] = try await ASCService.list(filters: [filter], limit: nil)

        guard let firstId = ids.first else {
            throw AscError.noBundleIdFound(id)
        }
        _ = try await delete(model: firstId)
        return firstId
    }

    // MARK: Builds

    public static func expireBuilds(ids: [String]) async throws -> [Build] {

        typealias ResultType = Build

        let filters: [Filter]

        if ids.isEmpty {
            filters = [Filter(key: Build.FilterKey.expired, value: "false")]
        } else {
            filters = ids.map { Filter(key: Build.FilterKey.id, value: $0) }
        }

        let nonExpiredBuilds: [Build] = try await list(filters: filters)

        guard !nonExpiredBuilds.isEmpty else {
            throw AscError.noBuildsFound
        }

        var results: [ResultType] = []
        var errors: [Error] = []

        await withTaskGroup(of: Result<ResultType, Error>.self) { group in
            for build in nonExpiredBuilds {
                let endpoint = AscEndpoint.expireBuild(build)

                group.addTask {
                    do {
                        let result: ResultType = try await network.request(endpoint: endpoint)
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
            }

            for await result in group {
                switch result {
                case .success(let result): results.append(result)
                case .failure(let error): errors.append(error)
                }
            }
        }

        if !errors.isEmpty {
            #warning("In case of error attach successful builds to the error so the user knows that something HAS been expired.")
            throw AscError.requestFailed(underlyingErrors: errors)
        }

        return results
    }
}
