//
//  Filter.swift
//  ASCKit
//
//  Created by Stefan Herold on 08.09.20.
//

import Foundation

public struct Filter {

    public let key: AnyHashable
    public let value: String

    public init(key: AnyHashable, value: String) {
        self.key = key
        self.value = value
    }
}

// Generic Approach
//public protocol Filter {
//
//    associatedtype KeyType
//
//    var key: KeyType { get set }
//    var value: String { get set }
//}
//
//extension Filter {
//
//    public init(key: KeyType, value: String) {
//        self.key = key
//        self.value = value
//    }
//}

// Protocol aproach
//public protocol Filterable: Codable, RawRepresentable {
//
//}
//
//public struct Filter<KeyType: Filterable> {
//
//    public let key: KeyType
//    public let value: String
//
//    public init(key: KeyType, value: String) {
//        self.key = key
//        self.value = value
//    }
//}
