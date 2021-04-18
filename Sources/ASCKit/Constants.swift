//
//  Constants.swift
//  ASCKit
//
//  Created by Stefan Herold on 08.02.21.
//

import Foundation

public enum Constants {
    public static let defaultPageSize: UInt = 50
    public static let maxPageSize: UInt = 200
}

#if canImport(UIKit)
import UIKit

extension Constants {
    public static let buttonSize: CGFloat = 44
    public static let raster: CGFloat = 12
}
#endif
