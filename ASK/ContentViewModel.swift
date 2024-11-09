//
//  ContentViewModel.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI
import FirebaseAuth

class ContentViewModel: ObservableObject {
    @ObservedObject var loginManager = LoginManager.shared
    
    @Published var isLoading: Bool = false
    
    func checkIfLoggedIn() {
        isLoading = true
        
        if let email = LoginManager.loadUserEmail(),
           let password = LoginManager.loadUserPassword() {
            
            loginWithEmail(email: email, password: password)
        }
    }
    
    func loginWithEmail(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                self.isLoading = false
            } else {
                self.loginManager.isLoggedIn = true
                Task {
                    do {
                        try await self.loginManager.fetchUser()
                        self.isLoading = false
                    } catch {
                        print(error.localizedDescription)
                        self.isLoading = false
                    }
                }
            }
        }
    }
}
