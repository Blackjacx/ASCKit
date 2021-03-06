//
//  AscError.swift
//  ASCKit
//
//  Created by Stefan Herold on 09.09.20.
//

import Foundation

public enum AscError: Error {
    case noDataProvided(_ type: String)
    case noUserFound(_ email: String)
    case noBuildsFound
    case noApiKeysRegistered
    case invalidInput(_ message: String)
    case apiKeyNotFound(_ id: String)
    case requestFailed(underlyingErrors: [Error])
}
