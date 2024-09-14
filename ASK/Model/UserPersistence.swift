//
//  UserPersistence.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import Foundation

struct UserPersistence {
    private static let userEmailKey = "savedUserEmail"
    private static let userPasswordKey = "savedUserPassword"
    private static let userUIDKey = "savedUserUID"
    
    static func saveUser(uid: String, email: String, password: String) {
        UserDefaults.standard.set(uid, forKey: userUIDKey)
        UserDefaults.standard.set(email, forKey: userEmailKey)
        UserDefaults.standard.set(password, forKey: userPasswordKey)
    }

    static func loadUserUID() -> String? {
        return UserDefaults.standard.string(forKey: userUIDKey)
    }
    
    static func loadUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: userEmailKey)
    }
    
    static func loadUserPassword() -> String? {
        return UserDefaults.standard.string(forKey: userPasswordKey)
    }
    
    static func clearUser() {
        UserDefaults.standard.removeObject(forKey: userUIDKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)
        UserDefaults.standard.removeObject(forKey: userPasswordKey)
    }
}
