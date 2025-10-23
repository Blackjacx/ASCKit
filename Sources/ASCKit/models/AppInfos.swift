//
//  AppInfo.swift
//  ASCKit
//
//  Created by Stefan Herold on 23.10.25.
//

import Foundation

public struct AppInfos: IdentifiableModel {
    public var id: String
    public var type: String

    public var name: String {
        id
    }
}
