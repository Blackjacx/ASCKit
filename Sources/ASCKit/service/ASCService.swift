//
//  Network+Requests.swift
//  ASCKit
//
//  Created by Stefan Herold on 27.05.20.
//

import Foundation
import Engine
import Combine

public struct ASCService {

    static let network = Network.shared

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

    /// Generic, throwable function to return any list of `IdentifiableModel`s.
    /// - note: Suitable for CLI tools
    public static func list<P: IdentifiableModel>(filters: [Filter] = [], limit: UInt? = nil) async throws -> [P] {
        let loader = PagedItemLoader<P>(filters: filters, limit: limit)
        try await loader.loadMoreIfNeeded()
        return loader.items
    }

    // MARK: - Apps

    @discardableResult
    public static func listAppStoreVersions(appIds: [String],
                                            filters: [Filter] = [],
                                            limit: UInt? = nil) async throws -> [(app: App, versions: [AppStoreVersion])] {

        let apps: [App] = try await list()
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map({ $0.id })
        var appVersionTuple: [(app: App, versions: [AppStoreVersion])] = []
        var errors: [Error] = []

        for id in iterableAppIds {
            let app = apps.first(where: { $0.id == id })!
            let endpoint = AscEndpoint.listAppStoreVersions(appId: id, filters: filters, limit: limit)
            do {
                let versions: [AppStoreVersion] = try await network.request(endpoint: endpoint)
                appVersionTuple.append((app: app, versions: versions))
            } catch {
                errors.append(error)
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }

        return appVersionTuple
    }

    // MARK: - BetaTester

    public static func inviteBetaTester(email: String, appIds: [String]) async throws {

        let apps: [App] = try await list()
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map({ $0.id })
        guard iterableAppIds.count > 0 else {
            throw AscError.noDataProvided("app_ids")
        }

        guard let tester: BetaTester = try await list(filters: [Filter(key: BetaTester.FilterKey.email, value: email)]).first else {
            throw AscError.noUserFound(email)
        }

        var receivedObjects: [BetaTesterInvitationResponse] = []
        var errors: [Error] = []

        for id in iterableAppIds {
            let app = apps.first { id == $0.id }!
            let endpoint = AscEndpoint.inviteBetaTester(testerId: tester.id, appId: id)
            do {
                let result: BetaTesterInvitationResponse = try await network.request(endpoint: endpoint)
                receivedObjects.append(result)
                print("Invited tester \(tester.name)  (\(tester.id)) to app \(app.name) (\(id))")
            } catch {
                print("Failed inviting tester \(tester.name) (\(tester.id)) to app \(app.name) (\(id))")
                errors.append(error)
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
    }

    public static func addBetaTester(email: String,
                                     first: String,
                                     last: String, groupNames: [String]) async throws {

        let groupFilters: [Filter] = groupNames
            // create filters for group names
            .map({ Filter(key: BetaGroup.FilterKey.name, value: $0) })

        var betaGroups: Set<BetaGroup> = []

        for filter in groupFilters {
            // union of groups of different names
            betaGroups.formUnion(try await list(filters: [filter]))
        }

        var receivedObjects: [BetaTester] = []
        var errors: [Error] = []

        for id in betaGroups.map(\.id) {
            let endpoint = AscEndpoint.addBetaTester(email: email, firstName: first, lastName: last, groupId: id)
            do {
                let tester: BetaTester = try await network.request(endpoint: endpoint)
                receivedObjects.append(tester)
                let betaGroup = betaGroups.filter { id == $0.id }[0]
                print("Added tester: \(tester.name), email: \(email), id: \(tester.id) to group: \(betaGroup.name), id: \(id)")
            } catch {
                errors.append(error)
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
    }
}
