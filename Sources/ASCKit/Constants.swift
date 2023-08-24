//
//  Constants.swift
//  ASCKit
//
//  Created by Stefan Herold on 08.02.21.
//

import Foundation

public enum Constants {
    /// The max allowed page size by Apple is `200`
    public static let defaultPageSize: UInt = 200
    public static let maxAllowedPageSize: UInt = 200

    public static func defaultLimit(_ givenLimit: UInt?) -> UInt {
        guard let givenLimit else {
            return defaultPageSize
        }
        return min(givenLimit, maxAllowedPageSize)
    }
}

#if canImport(UIKit)
import UIKit

extension Constants {
    public static let buttonSize: CGFloat = 44
    public static let raster: CGFloat = 12
}
#endif
