//
//  ASCPayload.swift
//  ASCKit
//
//  Created by Stefan Herold on 16.02.2025.
//

import Engine
import Foundation

struct ASCPayload: JWTClaims {
    let aud: String? = "appstoreconnect-v1"
    let iat: Date = Date()
    let exp: Date? = Date().addingTimeInterval(20 * 60) // 20 minutes
    let iss: String
}
