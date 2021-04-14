//
//  ApiKeysOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 18.11.20.
//

import Foundation
import Engine

public final class ApiKeysOperation: AsyncResultOperation<[ApiKey], Swift.Error> {

    public enum SubCommand {
        case list
        case activate(id: String)
        case register(key: ApiKey)
        case delete(id: String)
    }

    /// Collection of registered API keys
    @Defaults("\(ProcessInfo.processId).apiKeys", defaultValue: []) private static var apiKeys: [ApiKey]

    /// For command line applications set to the key ID passed as parameter
    public static var specifiedKeyId: String?

    private let subcommand: SubCommand  

    public init(_ subcommand: SubCommand) {
        self.subcommand = subcommand
    }

    public override func main() {

        switch subcommand {
        case .list:
            finish(with: .success(Self.apiKeys))

        case .activate(let id):
            guard activate(id: id) != nil else {
                finish(with: .failure(AscError.apiKeyNotFound(id)))
                return
            }
            finish(with: .success(Self.apiKeys))

        case .register(let key):
            register(key: key)
            finish(with: .success(Self.apiKeys))

        case .delete(let id):
            guard delete(id: id) != nil else {
                finish(with: .failure(AscError.apiKeyNotFound(id)))
                return
            }
            finish(with: .success(Self.apiKeys))
        }
    }

    // MARK: - Helper

    @discardableResult
    private func activate(id: String) -> ApiKey? {

        guard let matchingKey = Self.apiKeys.first(where: { $0.id == id }) else {
            return nil
        }
        Self.apiKeys.indices.forEach { Self.apiKeys[$0].isActive = Self.apiKeys[$0].id == matchingKey.id }
        return Self.apiKeys.first { $0.isActive }
    }

    @discardableResult
    private func register(key: ApiKey) -> ApiKey {

        Self.apiKeys.append(key)
        // Activate in case we don't have an active key
        if !hasActiveKey {
            activate(id: key.id)
        }
        return key
    }

    @discardableResult
    private func delete(id: String) -> ApiKey? {

        guard let matchingKey = Self.apiKeys.first(where: { id == $0.id }) else {
            return nil
        }
        Self.apiKeys = Self.apiKeys.filter { $0.id != id }
        return matchingKey
    }

    private var hasActiveKey: Bool {
        Self.apiKeys.contains { $0.isActive }
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
}
