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

    #warning("""
        return a publisher that loads all pages when limit is nil.
        https://www.donnywals.com/recursively-execute-a-paginated-network-call-with-combine/
    """)
    /// Generic function to get pageable models for each model of the ASC API. Automatically evaluates the previous
    /// result or fetches the first page if nil.
    /// - note: Suitable for SwiftUI Apps
    public static func list<P: Pageable>(previousPageable: P?,
                                         filters: [Filter] = [],
                                         limit: UInt? = nil) -> AnyPublisher<P, NetworkError> {
        let endpoint: AscGenericEndpoint<P.ModelType>
        if let nextUrl = previousPageable?.nextUrl {
            endpoint = AscGenericEndpoint.url(nextUrl, type: P.ModelType.self)
        } else {
            endpoint = AscGenericEndpoint.list(type: P.ModelType.self, filters: filters, limit: limit)
        }
        return network.request(endpoint: endpoint)
    }

    /// Generic, throwable function to return any list of `IdentifiableModel`s.
    /// - note: Suitable for CLI tools
    public static func list<P: IdentifiableModel>(filters: [Filter] = [], limit: UInt? = nil) throws -> [P] {
        let loader = PagedItemLoader<P>(filters: filters, limit: limit)
        loader.loadMoreIfNeeded()
        while loader.isLoading { RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1)) }
        if let error = loader.error { throw error }
        return loader.items
    }

    // MARK: - Apps

    @discardableResult
    public static func listAppStoreVersions(appIds: [String],
                                            filters: [Filter] = [],
                                            limit: UInt? = nil) throws -> [(app: App, versions: [AppStoreVersion])] {

        let apps: [App] = try list()
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map({ $0.id })
        var appVersionTuple: [(app: App, versions: [AppStoreVersion])] = []
        var errors: [Error] = []

        for id in iterableAppIds {
            let endpoint = AscEndpoint.listAppStoreVersions(appId: id, filters: filters, limit: limit)
            let result: RequestResult<[AppStoreVersion]> = network.syncRequest(endpoint: endpoint)

            switch result {
            case let .success(versions):
                let app = apps.first(where: { $0.id == id })!
                appVersionTuple.append((app: app, versions: versions))
            case let .failure(error):
                errors.append(error)
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }

        return appVersionTuple
    }

    // MARK: - BetaTester

    public static func inviteBetaTester(email: String, appIds: [String]) throws {

        let apps: [App] = try list()
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map({ $0.id })
        guard iterableAppIds.count > 0 else {
            throw AscError.noDataProvided("app_ids")
        }

        guard let tester: BetaTester = try list(filters: [Filter(key: BetaTester.FilterKey.email, value: email)]).first else {
            throw AscError.noUserFound(email)
        }

        var receivedObjects: [BetaTesterInvitationResponse] = []
        var errors: [Error] = []

        for id in iterableAppIds {
            let endpoint = AscEndpoint.inviteBetaTester(testerId: tester.id, appId: id)
            let result: RequestResult<BetaTesterInvitationResponse> = network.syncRequest(endpoint: endpoint)
            let app = apps.filter { id == $0.id }[0]

            switch result {
            case let .success(result):
                receivedObjects.append(result)
                print("Invited tester \(tester.name)  (\(tester.id)) to app \(app.name) (\(id))")
            case let .failure(error):
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
                                     last: String, groupNames: [String]) throws {

        let betaGroups: Set<BetaGroup> = try groupNames
            // create filters for group names
            .map({ Filter(key: BetaGroup.FilterKey.name, value: $0) })
            // union of groups of different names
            .reduce([], { $0.union(try list(filters: [$1])) })

        var receivedObjects: [BetaTester] = []
        var errors: [Error] = []

        for id in betaGroups.map(\.id) {
            let endpoint = AscEndpoint.addBetaTester(email: email, firstName: first, lastName: last, groupId: id)
            let result: RequestResult<BetaTester> = network.syncRequest(endpoint: endpoint)

            switch result {
            case let .success(result):
                receivedObjects.append(result)
                let betaGroup = betaGroups.filter { id == $0.id }[0]
                print("Added tester: \(result.name), email: \(email), id: \(result.id) to group: \(betaGroup.name), id: \(id)")
            case let .failure(error): errors.append(error)
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
    }
}
