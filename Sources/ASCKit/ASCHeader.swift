//
//  Header.swift
//  ASCKit
//
//  Created by Stefan Herold on 16.02.2025.
//

import Engine
import Foundation

struct ASCHeader: JWTHeader {    
    let alg: String? = "ES256"
    let typ: String = "JWT"
    let kid: String
}

