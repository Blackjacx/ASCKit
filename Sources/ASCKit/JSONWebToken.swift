//
//  JSONWebToken.swift
//  ASCKit
//
//  Created by Stefan Herold on 19.06.20.
//

import Foundation
import JWTKit

public struct JSONWebToken {

    public static func create(keyFile: String, kid: String, iss: String) throws -> String {

        let claims = JWTClaims(iss: iss,
                               exp: Date(timeIntervalSinceNow: 20 * 60),
                               aud: "appstoreconnect-v1",
                               alg: "ES256")

        let signers = JWTSigners()

        guard let keyData = FileManager.default.contents(atPath: keyFile) else {
            throw Error.fileNotFound(keyFile)
        }

        try signers.use(.es256(key: .private(pem: keyData)))

        let jwt = try signers.sign(claims, kid: JWKIdentifier(string: kid)).trimmingCharacters(in: .whitespacesAndNewlines)
        return jwt
    }
}

private extension JSONWebToken {

    enum Error: Swift.Error {
        case credentialsNotSet
        case unableToConstructJWT
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
