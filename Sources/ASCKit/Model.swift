//
//  Model.swift
//  ASCKit
//
//  Created by Stefan Herold on 18.06.20.
//

import Foundation

public protocol Model: Codable, Hashable {}

public protocol Pageable: Model {
    associatedtype ModelType: Model

    var data: [ModelType] { get }
    var totalCount: UInt { get }
    var limit: UInt { get }
    var nextUrl: URL? { get }
}

public protocol IdentifiableModel: Model, Identifiable {
    var id: String { get }
    var name: String { get }
}

extension Array where Self.Element: IdentifiableModel {

    func out<T>(_ keyPath: KeyPath<Element, T>, attribute: String? = nil) {
        map { (id: $0.id, property: $0[keyPath: keyPath]) }.forEach { print("id: \($0.id), \(attribute ?? "property"): \($0.property)") }
        //        let joined = map { "\($0[keyPath: keyPath])" }.joined(separator: " ")
        //        print(joined)
    }

    func out() {
        forEach { print( $0.id ) }
    }

    var allIds: [String] {
        map { $0.id }
    }

    var allNames: [String] {
        map { $0.name }
    }
}
