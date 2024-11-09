//
//  LoginManager.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import Foundation
import SwiftUI

class LoginManager: ObservableObject {
    static var shared = LoginManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    private static let userEmailKey = "savedUserEmail"
    private static let userPasswordKey = "savedUserPassword"
    private static let userUIDKey = "savedUserUID"
    
    func fetchUser() async throws {
        let user = try await FirestoreAPI.fetchUser(userID: LoginManager.loadUserUID()!)
        await MainActor.run {
            self.currentUser = user
        }
    }
    
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
