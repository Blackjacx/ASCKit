//
//  JSONWebToken.swift
//  ASCKit
//
//  Created by Stefan Herold on 19.06.20.
//

import Foundation
import JWTKit

public struct JSONWebToken {

    public static func create(privateKeySource: PrivateKeySource, kid: String, iss: String) throws -> String {

        let claims = JWTClaims(iss: iss,
                               exp: Date(timeIntervalSinceNow: 20 * 60),
                               aud: "appstoreconnect-v1",
                               alg: "ES256")

        let signers = JWTSigners()
        let keyData: Data

        switch privateKeySource {
        case .localFilePath(let path):
            guard let data = FileManager.default.contents(atPath: path) else {
                throw Error.fileNotFound(path)
            }
            keyData = data
        case .keychain(let keychainKey):
            guard let data = ASCKit.keychain.keychainItem(for: keychainKey)?.data(using: .utf8) else {
                throw Error.keychainItemNotFound(keychainKey)
            }
            keyData = data
        case .inline(let privateKey):
            guard let data = privateKey.data(using: .utf8) else {
                throw Error.conversionFailed
            }
            keyData = data
        }

        try signers.use(.es256(key: .private(pem: keyData)))

        let jwt = try signers.sign(claims, kid: JWKIdentifier(string: kid)).trimmingCharacters(in: .whitespacesAndNewlines)
        return jwt
    }
}

public extension JSONWebToken {

    enum PrivateKeySource: Equatable, Hashable {
        case localFilePath(path: String)
        case keychain(keychainKey: String)
        case inline(privateKey: String)
    }
}

extension JSONWebToken.PrivateKeySource: Codable {

    enum CodingKeys: CodingKey {
        case localFilePath, keychain, inline
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .localFilePath(let path):
            try container.encode(path, forKey: .localFilePath)
        case .keychain(let keychainKey):
            try container.encode(keychainKey, forKey: .keychain)
        case .inline(let privateKey):
            try container.encode(privateKey, forKey: .inline)
        }
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .localFilePath:
            let path = try container.decode(String.self, forKey: .localFilePath)
            self = .localFilePath(path: path)
        case .keychain:
            let keychainKey = try container.decode(String.self, forKey: .keychain)
            self = .keychain(keychainKey: keychainKey)
        case .inline:
            let privateKey = try container.decode(String.self, forKey: .inline)
            self = .inline(privateKey: privateKey)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
}

private extension JSONWebToken {

    enum Error: Swift.Error {
        case credentialsNotSet
        case unableToConstructJWT
        case keychainItemNotFound(String)
        case conversionFailed
        case fileNotFound(String)
        case privateKeyInvalid
        case privateKeyEmpty
        case keyContainsNoData(String)
        case googleServiceAccountJsonNotFound(path: String)
    }
}

private struct JWTClaims: JWTPayload {

    let iss: String
    let exp: Date?
    let aud: String
    let alg: String

    func verify(using signer: JWTSigner) throws {}
}
