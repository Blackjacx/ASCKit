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
