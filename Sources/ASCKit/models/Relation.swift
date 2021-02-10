//
//  Relation.swift.swift
//  ASCKit
//
//  Created by Stefan Herold on 20.07.20.
//

import Foundation

struct Relation: Model {
    var links: Links
}

struct Links: Model {
    var related: URL
    var `self`: URL
}
