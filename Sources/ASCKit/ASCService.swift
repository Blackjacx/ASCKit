//
//  Network+Requests.swift
//  ASCKit
//
//  Created by Stefan Herold on 27.05.20.
//

import Foundation
import Engine

public struct ASCService {

    static let network = Network()

    // MARK: - Apps

    @discardableResult
    public static func listAppStoreVersions(appIds: [String],
                                            filters: [Filter] = [],
                                            limit: UInt? = nil) throws -> [(app: App, versions: [AppStoreVersion])] {

        let apps = try listApps()
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

        let apps = try listApps()
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map({ $0.id })
        guard iterableAppIds.count > 0 else {
            throw AscError.noDataProvided("app_ids")
        }

        guard let tester = try listBetaTester(filters: [Filter(key: BetaTester.FilterKey.email, value: email)]).first else {
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
            .reduce([], { $0.union(try listBetaGroups(filters: [$1])) })

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

    public static func deleteBetaTester(emails: [String]) throws {

        guard !emails.isEmpty else { throw AscError.noDataProvided("emails") }

        let filter = Filter(key: BetaTester.FilterKey.email, value: emails.joined(separator: ","))
        let foundTesters = try listBetaTester(filters: [filter])

        // Don't throw, just return to print nothing
        guard !foundTesters.isEmpty else {
            print("No testers found.")
            return
        }

        var receivedObjects: [EmptyResponse] = []
        var errors: [Error] = []

        for tester in foundTesters {
            let endpoint = AscGenericEndpoint.delete(type: BetaTester.self, id: tester.id)
            let result: RequestResult<EmptyResponse> = network.syncRequest(endpoint: endpoint)

            switch result {
            case let .success(result):
                receivedObjects.append(result)
                var messages = ["Removed \(tester.name) from all groups."]
                if let email = tester.attributes.email { messages.append("(\(email))")}
                print(messages.joined(separator: " "))
            case let .failure(error): errors.append(error)
            }
        }

        if !errors.isEmpty {
            throw AscError.requestFailed(underlyingErrors: errors)
        }
    }

    // MARK: - DEPRECATED

    /// This will be transformed to a dependent operation once beta testers is realized as operation too
    static func listBetaGroups(filters: [Filter] = []) throws -> [BetaGroup] {
        let endpoint = AscGenericEndpoint.list(type: BetaGroup.self, filters: filters, limit: nil)
        let result: RequestResult<[BetaGroup]> = network.syncRequest(endpoint: endpoint)
        return try result.get()
    }

    /// This will be transformed to a dependent operation once beta testers is realized as operation too
    static func listBetaTester(filters: [Filter] = []) throws -> [BetaTester] {
        let endpoint = AscGenericEndpoint.list(type: BetaTester.self, filters: filters, limit: nil)
        let result: RequestResult<[BetaTester]> = network.syncRequest(endpoint: endpoint)
        return try result.get()
    }

    /// This will be transformed to a dependent operation once beta testers is realized as operation too
    static func listApps(filters: [Filter] = []) throws -> [App] {
        let endpoint = AscGenericEndpoint.list(type: App.self, filters: filters, limit: nil)
        let result: RequestResult<[App]> = network.syncRequest(endpoint: endpoint)
        return try result.get()
    }
}
