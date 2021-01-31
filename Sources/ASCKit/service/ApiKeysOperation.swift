//
//  ApiKeysOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 18.11.20.
//

import Foundation
import Engine

public final class ApiKeysOperation: AsyncOperation, Command {

    public enum SubCommand {
        case list
        case register(key: ApiKey)
        case delete(keyId: String)
    }

    /// Collection of registered API keys
    @Defaults("\(ProcessInfo.processId).apiKeys", defaultValue: []) private static var apiKeys: [ApiKey]

    public private(set)var result: Result<[ApiKey], AscError>!

    private let subcommand: SubCommand  

    public init(_ subcommand: SubCommand) {
        self.subcommand = subcommand
    }

    public override func main() {

        defer {
            self.state = .finished
        }

        switch subcommand {
        case .list:
            result = .success(Self.apiKeys)

        case .register(let key):
            Self.apiKeys.append(key)
            result = .success([key])

        case .delete(let keyId):
            guard let key = Self.apiKeys.first(where: { keyId == $0.keyId }) else {
                result = .failure(.apiKeyNotFound(keyId))
                return
            }
            Self.apiKeys = Self.apiKeys.filter { $0.keyId != keyId }
            result = .success([key])
        }
    }
}
