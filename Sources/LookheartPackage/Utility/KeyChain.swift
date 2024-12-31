//
//  File.swift
//  
//
//  Created by KHJ on 2024/04/29.
//

import Foundation
import KeychainSwift

public class Keychain {
    public static let shared = Keychain()
    
    private let keychain = KeychainSwift()

    public func setString(_ value: String, forKey key: String) {
        keychain.set(value, forKey: key)
    }
    
    public func getString(forKey key: String) -> String? {
        return keychain.get(key)
    }
    
    public func setBool(_ value: Bool, forKey key: String) {
        keychain.set(value, forKey: key)
    }
    
    public func getBool(forKey key: String) -> Bool {
        return keychain.getBool(key) ?? false
    }
    
    public func deleteString(forKey key: String) -> Bool {
        return keychain.delete(key)
    }
    
    public func clear() -> Bool {
        return keychain.clear()
    }
}
