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
