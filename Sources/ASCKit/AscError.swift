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
    case noBundleIdFound(_ id: String)
    case noBuildsFound
    case noApiKeysRegistered
    case invalidInput(_ message: String)
    case apiKeyNotFound(_ id: String)
    case apiKeyActivationFailed(_ key: ApiKey)
    case requestFailed(underlyingErrors: [Error])
    case requestFailed(underlyingError: Error)
    /// Maps partial errors and includes IDs of the original objects passed to the request.
    case requestFailedPartially(underlyingErrors: [String: Error])

    case jsonStringToDataConversionFailed(_ json: String)
    case dataToJsonObjectConversionFailed(_ data: Data)
}
