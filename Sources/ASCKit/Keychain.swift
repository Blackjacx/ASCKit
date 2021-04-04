//
//  Keychain.swift
//  ASCKit
//
//  Created by Stefan Herold on 04.04.21.
//

import Foundation
import SwiftKeychainWrapper
import Engine

public struct Keychain {

    private let keychain = KeychainWrapper(serviceName: ProcessInfo.processId)
    private let persistentStore = UserDefaults.standard

    /// The private store properties for our keychain items to not pull them
    /// from the keychain if the app is still in memory. This allows us to
    /// bypass the locked keychain when iPhone is locked and the app is just in
    /// background.
    private var transientStore: [String: String] = [:]

    // MARK: - Public Interface

    public mutating func setKeychainItem(_ value: String, key: String) -> Bool {

        // Make sure to always set a Data object to the Keychain since
        // otherwise storing an item will give you unexpected behaviour.
        keychain.set(value, forKey: key)

        guard keychain.string(forKey: key) == value else {
            return false
        }
        transientStore[key] = value
        persistentStore.set(true, forKey: key)

        return true
    }

    public mutating func keychainItem(for key: String) -> String? {

        let hasKeychainItem = persistentStore.bool(forKey: key)

        guard hasKeychainItem else {
            removeKeychainItem(for: key)
            return nil
        }

        if let item = transientStore[key] {
            return item
        }

        guard let value = keychain.string(forKey: key) else {
            removeKeychainItem(for: key)
            return nil
        }

        transientStore[key] = value
        return value
    }

    public mutating func removeKeychainItem(for key: String) {

        transientStore[key] = nil
        persistentStore.setValue(nil, forKey: key)
        keychain.removeObject(forKey: key)
    }
}

