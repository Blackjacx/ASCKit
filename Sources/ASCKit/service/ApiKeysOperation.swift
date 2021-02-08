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
        case register(key: ApiKey)
        case delete(keyId: String)
    }

    /// Collection of registered API keys
    @Defaults("\(ProcessInfo.processId).apiKeys", defaultValue: []) private static var apiKeys: [ApiKey]

    private let subcommand: SubCommand  

    public init(_ subcommand: SubCommand) {
        self.subcommand = subcommand
    }

    public override func main() {

        switch subcommand {
        case .list:
            finish(with: .success(Self.apiKeys))

        case .register(let key):
            Self.apiKeys.append(key)
            finish(with: .success([key]))

        case .delete(let keyId):
            guard let key = Self.apiKeys.first(where: { keyId == $0.keyId }) else {
                finish(with: .failure(AscError.apiKeyNotFound(keyId)))
                return
            }
            Self.apiKeys = Self.apiKeys.filter { $0.keyId != keyId }
            finish(with: .success([key]))
        }
    }
}
