//
//  Network+Requests.swift
//  ASCKit
//
//  Created by Stefan Herold on 27.05.20.
//

import Engine
import Foundation

/// The central class to deal with the App Store Connect API. This object must
/// be equally compatible with CLI tools and SwiftUI apps. As an example no
/// code should be printed here what is the typical format of output for CLI
/// tools. Better handle this in the commands CLI tool itself.
public enum ASCService {

    static let network = Network.shared

    /// Collection of registered API keys
    @Defaults("\(ProcessInfo.processId).apiKeys", defaultValue: []) private static var apiKeys: [ApiKey]
    /// For command line applications set to the key ID passed as parameter
    public static var specifiedKeyId: String?

    // MARK: - Generic List

    /// Async/await function to generically get pageable models for each model
    /// of the ASC API. Automatically evaluates the previous result or fetches
    /// the first page if nil.
    /// - note: Suitable for both CLI tools and SwiftUI apps
    /// - throws: NetworkError
    public static func list<P: Pageable>(
        previousPageable: P?,
        filters: [Filter] = [],
        limit: UInt? = nil,
        outputType: OutputType,
    ) async throws -> P {
        let endpoint: AscGenericEndpoint<P.ModelType>
        if let nextUrl = previousPageable?.nextUrl {
            endpoint = AscGenericEndpoint.url(nextUrl, type: P.ModelType.self)
        } else {
            endpoint = AscGenericEndpoint.list(type: P.ModelType.self, filters: filters, limit: limit)
        }
        return try await network.request(
            endpoint: endpoint,
            outputType: outputType,
        )
    }

    /// Generic, throwable function to return any list of `IdentifiableModel`s.
    /// - note: Suitable for CLI tools
    public static func list<P: IdentifiableModel>(
        filters: [Filter] = [],
        limit: UInt? = nil,
        outputType: OutputType,
    ) async throws -> [P] {
        let loader = PagedItemLoader<P>(
            filters: filters,
            limit: limit,
            outputType: outputType,
        )
        try await loader.loadMoreIfNeeded()
        return loader.items
    }

    // MARK: Generic Delete

    public static func delete<M: IdentifiableModel>(
        model: M,
        outputType: OutputType,
    ) async throws -> EmptyResponse {
        let endpoint = AscGenericEndpoint.delete(type: M.self, id: model.id)
        return try await network.request(
            endpoint: endpoint,
            outputType: outputType,
        )
    }

    // MARK: - Creating Access Token

    public static func createAccessToken(keyId: String? = specifiedKeyId) async throws -> String {
        let key: ApiKey

        // Prefer key specified via parameter over activated one
        if let keyId {
            guard let matchingKey = apiKeys.first(where: { $0.id == keyId }) else {
                throw AscError.apiKeyNotFound(keyId)
            }
            key = matchingKey
        } else if let activeKey = apiKeys.first(where: { $0.isActive }) {
            // Go with active API key
            key = activeKey
        } else {
            throw AscError.noApiKeysRegistered
        }
        return try await JWT().create(
            keySource: key.source,
            header: ASCHeader(kid: key.id),
            payload: ASCPayload(iss: key.issuerId)
        )
    }

    // MARK: API Keys

    public static func listApiKeys() -> [ApiKey] {
        apiKeys
    }

    @discardableResult
    public static func activateApiKey(id: String) throws -> ApiKey {
        guard let matchingKey = apiKeys.first(where: { $0.id == id }) else {
            throw AscError.apiKeyNotFound(id)
        }
        Self.apiKeys.indices.forEach { Self.apiKeys[$0].isActive = Self.apiKeys[$0].id == matchingKey.id }

        guard let matchingActiveKey = Self.apiKeys.first(where: { $0.id == id && $0.isActive }) else {
            throw AscError.apiKeyActivationFailed(matchingKey)
        }
        return matchingActiveKey
    }

    public static func registerApiKey(key: ApiKey) throws -> ApiKey {
        apiKeys.append(key)
        // Activate in case we don't have an active key
        if !hasActiveKey {
            try activateApiKey(id: key.id)
        }
        return key
    }

    public static func deleteApiKey(id: String) throws -> ApiKey {
        guard let matchingKey = apiKeys.first(where: { id == $0.id }) else {
            throw AscError.apiKeyNotFound(id)
        }
        Self.apiKeys = Self.apiKeys.filter { $0.id != id }
        return matchingKey
    }

    private static var hasActiveKey: Bool {
        apiKeys.contains { $0.isActive }
    }

    // MARK: - AccessibilityDeclaration

    @discardableResult
    public static func listAccessibilityDeclarations(
        appId: String,
        filters: [Filter] = [],
        limit: UInt? = nil,
        outputType: OutputType,
    ) async throws -> [AccessibilityDeclaration] {
        let endpoint = AscEndpoint.listAccessibilityDeclarations(
            appId: appId,
            filters: filters,
            limit: limit
        )
        return try await request(endpoint: endpoint, outputType: outputType)
    }

    @discardableResult
    public static func createAccessibilityDeclaration(
        appId: String,
        deviceFamily: AccessibilityDeclaration.DeviceFamily,
        parameters: String,
        outputType: OutputType,
    ) async throws -> AccessibilityDeclaration {
        let jsonObject = try Self.jsonObject(from: parameters)
        guard let parameterDict = jsonObject as? [String: Any] else {
            throw AscError.invalidInput("Expected dictionary, got \(jsonObject.self).")
        }
        let endpoint = AscEndpoint.createAccessibilityDeclaration(
            appId: appId,
            deviceFamily: deviceFamily,
            parameters: parameterDict,
        )
        return try await request(endpoint: endpoint, outputType: outputType)
    }

    @discardableResult
    public static func updateAccessibilityDeclaration(
        id: String,
        parameters: String,
        outputType: OutputType,
    ) async throws -> AccessibilityDeclaration {
        let jsonObject = try Self.jsonObject(from: parameters)
        guard let parameterDict = jsonObject as? [String: Any] else {
            throw AscError.invalidInput(
                "Expected dictionary, got \(jsonObject.self)."
            )
        }
        let endpoint = AscEndpoint.updateAccessibilityDeclaration(
            id: id,
            parameters: parameterDict,
        )
        return try await request(endpoint: endpoint, outputType: outputType)
    }

    @discardableResult
    public static func deleteAccessibilityDeclaration(
        id: String,
        outputType: OutputType,
    ) async throws -> EmptyResponse {
        let endpoint = AscEndpoint.deleteAccessibilityDeclaration(
            id: id,
        )
        return try await request(endpoint: endpoint, outputType: outputType)
    }

    @discardableResult
    public static func publishAccessibilityDeclaration(
        id: String,
        outputType: OutputType,
    ) async throws -> AccessibilityDeclaration {
        let endpoint = AscEndpoint.publishAccessibilityDeclaration(
            id: id,
        )
        return try await request(endpoint: endpoint, outputType: outputType)
    }

    @discardableResult
    public static func extendedPublishAccessibilityDeclaration(
        appId: String,
        deviceFamily: AccessibilityDeclaration.DeviceFamily,
        parameters: String,
        outputType: OutputType,
    ) async throws -> [AccessibilityDeclaration] {
        let jsonObject = try Self.jsonObject(from: parameters)
        guard let parameterDict = jsonObject as? [String: Any] else {
            throw AscError.invalidInput("Expected dictionary, got \(jsonObject.self).")
        }
        guard parameterDict["publish"] == nil else {
            throw AscError
                .invalidInput(
                    "'publish' parameter is not allowed when publishing an accessibility declaration. It's automatically added"
                )
        }
        guard !parameterDict.isEmpty else {
            throw AscError.invalidInput("'parameters' should not be empty when publishing an accessibility declaration.")
        }

        let existingDraftDeclarations = try await listAccessibilityDeclarations(
            appId: appId,
            filters: [
                Filter(
                    key: AccessibilityDeclaration.FilterKey.state,
                    value: AccessibilityDeclaration.State.draft.rawValue
                )
            ],
            outputType: .none,
        )
        var publishedDeclarations: [AccessibilityDeclaration] = []

        if existingDraftDeclarations.isEmpty {
            let created = try await createAccessibilityDeclaration(
                appId: appId,
                deviceFamily: deviceFamily,
                parameters: parameters,
                outputType: .none,
            )
            publishedDeclarations.append(
                try await publishAccessibilityDeclaration(
                    id: created.id,
                    outputType: outputType,
                )
            )
        } else {
            for draft in existingDraftDeclarations {
                let updated = try await updateAccessibilityDeclaration(
                    id: draft.id,
                    parameters: parameters,
                    outputType: .none,
                )
                publishedDeclarations.append(
                    try await publishAccessibilityDeclaration(
                        id: updated.id,
                        outputType: outputType,
                    )
                )
            }
        }

        return publishedDeclarations
    }

    // MARK: - Apps

    @discardableResult
    public static func listAppStoreVersions(
        appIds: [String],
        filters: [Filter] = [],
        limit: UInt? = nil,
        outputType: OutputType,
    ) async throws -> [(app: App, versions: [AppStoreVersion])] {
        typealias ResultType = (app: App, versions: [AppStoreVersion])

        let apps: [App] = try await list(outputType: .none)
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map { $0.id }
        var results: [ResultType] = []
        var errors: [Error] = []

        await withTaskGroup(of: Result<ResultType, Error>.self) { group in
            for id in iterableAppIds {
                let app = apps.first { $0.id == id }!
                let endpoint = AscEndpoint.listAppStoreVersions(appId: id, filters: filters, limit: limit)

                group.addTask {
                    do {
                        return .success(
                            (
                                app,
                                versions: try await network.request(
                                    endpoint: endpoint,
                                    outputType: outputType,
                                )
                            )
                        )
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

    // MARK: - App Infos

    @discardableResult
    public static func listAppInfos(
        appId: String,
        includedResources: [AppInfoResponse.IncludedResource.Types] = [],
        limit: UInt? = nil,
        outputType: OutputType,
    ) async throws -> AppInfoResponse {
        let endpoint = AscEndpoint.listAppInfos(
            appId: appId,
            includedResources: includedResources,
            limit: limit,
        )
        return try await request(endpoint: endpoint, outputType: outputType)
    }

    // MARK: - Age Ratings

    @discardableResult
    public static func getAgeRatingDeclaration(
        appInfoId: String,
        outputType: OutputType,
    ) async throws -> AgeRatingDeclaration {
        let endpoint = AscEndpoint.getAgeRatings(
            appInfoId: appInfoId
        )
        return try await request(endpoint: endpoint, outputType: outputType)
    }

    @discardableResult
    public static func listAgeRatingDeclarations(
        appId: String,
        outputType: OutputType,
    ) async throws -> [AgeRatingDeclaration] {
        let appInfosResponse = try await listAppInfos(
            appId: appId,
            outputType: .none
        )
        var results: [AgeRatingDeclaration] = []
        for appInfo in appInfosResponse.data {
            results.append(
                try await getAgeRatingDeclaration(
                    appInfoId: appInfo.id,
                    outputType: outputType
                )
            )
        }
        return results
    }

    @discardableResult
    public static func updateAgeRatings(
        appId: String,
        parameters: String,
        outputType: OutputType,
    ) async throws -> [AgeRatingDeclaration] {
        // Convert JSON parameter string to JSON dictionary

        let jsonObject = try Self.jsonObject(from: parameters)
        guard let parameterDict = jsonObject as? [String: Any] else {
            throw AscError.invalidInput(
                "Expected dictionary, got \(jsonObject.self)."
            )
        }

        // Determine editable app infos

        let appInfosResponse = try await listAppInfos(
            appId: appId,
            includedResources: [.ageRatingDeclaration],
            outputType: .none
        )

        let editableStates: Set<AppStoreVersion.State> = [
            .developerRejected,
            .rejected,
            .waitingForReview,
            .prepareForSubmission,
            .waitingForExportCompliance,
            .invalidBinary,
            .metadataRejected,
            .pendingDeveloperRelease,
        ]
        let editableAppInfos = appInfosResponse.data.filter {
            editableStates.contains($0.attributes.state)
        }
        guard !editableAppInfos.isEmpty else {
            throw AscError.invalidInput("""
                No editable app infos found for '\(appId)'. Available app info states are: 
                \(appInfosResponse.data.map(\.attributes.state))
                """
            )
        }

        let editableAgeRatings: [AgeRatingDeclaration] = appInfosResponse.included?.compactMap {
            guard case let .ageRatingDeclaration(value) = $0,
                  // YES - luckily the ID of the AgeRatingDeclaration matches
                  // the ID of its corresponding AppInfo. If this changes some
                  // day we need some kind of reference back to the app info
                  // object. Or to simplify things we fallback to the commented
                  // part below.
                  editableAppInfos.map(\.id).contains(value.id) else {
                return nil
            }
            return value
        } ?? []

        guard !editableAgeRatings.isEmpty else {
            throw AscError.invalidInput("""
                We found editable app infos but no editable age ratings. 
                Something went wrong during filtering. Please check. 
                """
            )
        }

        // Fetch age rating declaration for each app info object in parallel.
        // ⚠️ This can be done much more efficient by specifying inclusions for
        //    AppInfos. We can directly include the ageRatingDeclaration object
        //    in each app info response.

//        let editableAgeRatingsEndpointMapping = Dictionary(
//            uniqueKeysWithValues: editableAppInfos.map {
//                (
//                    $0.id,
//                    AscEndpoint.getAgeRatings(appInfoId: $0.id),
//                )
//            }
//        )
//        let editableAgeRatings: [AgeRatingDeclaration] = try await batchRequest(
//            endpointMapping: editableAgeRatingsEndpointMapping,
//            outputType: .none,
//        )

        // Update age rating declarations in parallel

        let updatedAgeRatingsEndpointMapping =  Dictionary(
            uniqueKeysWithValues: editableAgeRatings.map {
                (
                    $0.id,
                    AscEndpoint.updateAgeRatings(
                        ageRatingDeclarationId: $0.id,
                        parameters: parameterDict,
                    ),
                )
            }
        )
        let updatedAgeRatings: [AgeRatingDeclaration] = try await batchRequest(
            endpointMapping: updatedAgeRatingsEndpointMapping,
            outputType: outputType,
        )

        return updatedAgeRatings
    }

    // MARK: - Beta Testers

    public static func listBetaGroups(
        for betaTesters: [BetaTester],
        filters: [Filter] = [],
        limit: UInt? = nil,
        outputType: OutputType,
    ) async throws -> [BetaGroup] {
        let endpointMapping = Dictionary(
            uniqueKeysWithValues: betaTesters.map {
                (
                    $0.id,
                    AscEndpoint.listAllBetaGroupsForTester(
                        id: $0.id,
                        filters: filters,
                        limit: limit
                    ),
                )
            }
        )
        let results: [BetaGroup] = try await batchRequest(
            endpointMapping: endpointMapping,
            outputType: outputType,
        )
        return results
    }

    public static func inviteBetaTester(
        email: String,
        appIds: [String],
        outputType: OutputType,
    ) async throws {
        typealias ResultType = BetaTesterInvitationResponse

        let apps: [App] = try await list(outputType: .none)
        let iterableAppIds = appIds.count > 0 ? appIds : apps.map { $0.id }
        guard !iterableAppIds.isEmpty else {
            throw AscError.noDataProvided("app_ids")
        }

        guard let tester: BetaTester = try await list(
            filters: [Filter(key: BetaTester.FilterKey.email, value: email)],
            outputType: .none,
        ).first else {
            throw AscError.noUserFound(email)
        }

        var results: [ResultType] = []
        var errors: [Error] = []

        await withTaskGroup(of: Result<ResultType, Error>.self) { group in
            for id in iterableAppIds {
                let endpoint = AscEndpoint.inviteBetaTester(testerId: tester.id, appId: id)

                group.addTask {
                    do {
                        // FIXME: 🟢 convert to category-scoped OSLog outoput
//                        let app = apps.first { id == $0.id }!
//                        print("Invited tester \(tester.name)  (\(tester.id)) to app \(app.name) (\(id))")
                        return .success(
                            try await network.request(
                                endpoint: endpoint,
                                outputType: outputType,
                            )
                        )
                    } catch {
                        // FIXME: 🟢 convert to category-scoped OSLog outoput
//                        print("Failed inviting tester \(tester.name) (\(tester.id)) to app \(app.name) (\(id))")
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

    public static func addBetaTester(
        email: String,
        first: String,
        last: String,
        groupNames: [String],
        outputType: OutputType,
    ) async throws {
        typealias ResultType = BetaTester

        // create filters for group names
        let groupFilters: [Filter] = [
            Filter(key: BetaGroup.FilterKey.name, value: groupNames.joined(separator: ","))
        ]
        let betaGroups: [BetaGroup] = try await list(
            filters: groupFilters,
            outputType: .none,
        )

        var results: [ResultType] = []
        var errors: [Error] = []

        await withTaskGroup(of: Result<ResultType, Error>.self) { group in
            for betaGroup in betaGroups {
                let endpoint = AscEndpoint.addBetaTester(
                    email: email,
                    firstName: first,
                    lastName: last,
                    groupId: betaGroup.id
                )

                group.addTask {
                    do {
                        // FIXME: 🟢 convert to category-scoped OSLog outoput
//                        print(
//                            "Added tester: \(result.name), email: \(email), id: \(result.id) to group: \(betaGroup.name), id:
//                            \(betaGroup.id)"
//                        )
                        return .success(
                            try await network.request(
                                endpoint: endpoint,
                                outputType: outputType,
                            )
                        )
                    } catch {
                        // FIXME: 🟢 convert to category-scoped OSLog outoput
//                        print("Failed adding tester \(email) to group \(betaGroup.name) (\(betaGroup.id))")
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

    /// Searches beta testers based on the given filters and then deletes all
    /// of them.
    /// - parameters:
    ///  - filters: The filters used to search for matching beta testers.
    ///
    ///  It is possible to search for multiple users based on different filter
    ///  criteria at the same time, e.g.:
    ///    -f "firstName=Stefan"
    ///    -f "email=john.doe@ioki.com"
    ///    -f "email=jane.doe@ioki.com"
    @discardableResult
    public static func deleteBetaTesters(
        filters: [Filter],
        outputType: OutputType,
    ) async throws -> [BetaTester] {
        let allValidBetaGroups: [BetaGroup] = try await list(outputType: .none)
        var allDeletedTesters: [BetaTester] = []

        for filter in filters {
            // FIXME: 🟢 convert to category-scoped OSLog outoput
//            print("Processing beta tester for filter: \(filter)")

            // Get IDs of the beta testers
            // We have to search for each filter separately as each filter might
            // refer to a different tester.
            let testers: [BetaTester] = try await list(
                filters: [filter],
                outputType: .none,
            )

            // Either we can delete groups below or we cannot, because they are
            // somehow fucked up in Apple's database like the ones below. In the
            // latter case they are usually not part of `allValidBetaGroups`
            // anymore but are only "shadows of their past".
            //        User-Id: 8c7d99fb-775f-4b5e-a342-32d9cfb986ff
            //        {
            //            "id": "e27d7056-b689-4d2d-ab1c-8dfd94ac1b59"
            //        },
            //        {
            //            "id": "b072ee31-036f-482d-9c1d-952580bb0a6d"
            //        },
            //        {
            //            "id": "55e4783f-1470-46c0-bbd3-47cf3766d55e"
            //        },
            //        {
            //            "id": "917ccfe3-8508-43cc-b9e7-5b60eaa33f7b"
            //        }
            let allValidTesterGroups: [BetaGroup] = try await listBetaGroups(
                for: testers,
                outputType: .none,
            ).filter { allValidBetaGroups.map(\.id).contains($0.id) }

            guard !testers.isEmpty && !allValidTesterGroups.isEmpty else {
                // Skip deletion when no testers have been found
                continue
            }

            for tester in testers {
                _ = try await delete(
                    model: tester,
                    outputType: outputType,
                )
            }

            allDeletedTesters += testers
        }

        return allDeletedTesters
    }

    // MARK: BundleIDs

    @discardableResult
    public static func registerBundleId(
        _ identifier: String,
        name: String,
        platform: BundleId.Platform,
        seedId: String? = nil,
        outputType: OutputType,
    ) async throws -> BundleId {
        let attributes = BundleId.Attributes(
            identifier: identifier,
            name: name,
            platform: platform,
            seedId: seedId
        )
        let endpoint = AscEndpoint.registerBundleId(attributes: attributes)
        return try await request(endpoint: endpoint, outputType: outputType)
    }

    @discardableResult
    public static func deleteBundleId(
        _ id: String,
        outputType: OutputType,
    ) async throws -> BundleId {
        // Get id's
        let filter = Filter(key: BundleId.FilterKey.identifier, value: id)
        let ids: [BundleId] = try await ASCService.list(
            filters: [filter],
            limit: nil,
            outputType: .none,
        )
        guard let firstId = ids.first else {
            throw AscError.noBundleIdFound(id)
        }
        _ = try await delete(
            model: firstId,
            outputType: outputType,
        )
        return firstId
    }

    // MARK: Builds

    public static func expireBuilds(
        ids: [String],
        outputType: OutputType,
    ) async throws -> [Build] {
        let filters: [Filter]

        if ids.isEmpty {
            filters = [Filter(key: Build.FilterKey.expired, value: "false")]
        } else {
            filters = ids.map { Filter(key: Build.FilterKey.id, value: $0) }
        }

        let nonExpiredBuilds: [Build] = try await list(
            filters: filters,
            outputType: .none
        )

        guard !nonExpiredBuilds.isEmpty else {
            throw AscError.noBuildsFound
        }

        let endpointMapping = Dictionary(
            uniqueKeysWithValues: nonExpiredBuilds.map {
                (
                    $0.id,
                    AscEndpoint.expireBuild($0),
                )
            }
        )
        let results: [Build] = try await batchRequest(
            endpointMapping: endpointMapping,
            outputType: outputType,
        )
        return results
    }

    // MARK: - Helpers

    static func jsonObject(from jsonString: String) throws -> Any {
        guard let data = jsonString.data(using: .utf8) else {
            throw AscError.jsonStringToDataConversionFailed(jsonString)
        }

        do {
            return try JSONSerialization.jsonObject(with: data)
        } catch {
            throw AscError.dataToJsonObjectConversionFailed(data)
        }
    }

    /// Convenience function for condensing/simplifying many of the request
    /// functions above.
    private static func request<T: Decodable>(
        endpoint: Endpoint,
        outputType: OutputType,
    ) async throws -> T {
        do {
            return try await network.request(
                endpoint: endpoint,
                outputType: outputType,
            )
        } catch {
            throw AscError.requestFailed(underlyingError: error)
        }
    }

    private static func batchRequest<T: Decodable>(
        endpointMapping: [String: Endpoint],
        outputType: OutputType,
    ) async throws -> [T] {
        try await withThrowingTaskGroup(
            of: (String, Result<T, Error>).self
        ) { group in
            for (id, endpoint) in endpointMapping {
                group.addTask {
                    do {
                        let model: T = try await network.request(
                            endpoint: endpoint,
                            outputType: outputType
                        )
                        return (id, .success(model))
                    } catch {
                        return (id, .failure(error))
                    }
                }
            }

            var results: [T] = []
            var errors: [String: Error] = [:]

            // Collect results, separating successes and failures
            for try await (id, result) in group {
                switch result {
                case .success(let model):
                    results += [model]
                case .failure(let error):
                    errors[id] = error
                }
            }

            // If any fetches failed, throw a custom error
            if !errors.isEmpty {
                throw AscError.requestFailedPartially(underlyingErrors: errors)
            }

            return results
        }
    }
}
