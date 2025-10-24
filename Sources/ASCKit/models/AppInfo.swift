//
//  AppInfo.swift
//  ASCKit
//
//  Created by Stefan Herold on 23.10.25.
//

import Foundation

public struct AppInfo: IdentifiableModel {
    public var id: String
    public var type: String
    public var attributes: Attributes

    public var name: String {
        id
    }
}

public extension AppInfo {
    struct Attributes: Model {
        public var state: AppStoreVersion.State
    }
}
