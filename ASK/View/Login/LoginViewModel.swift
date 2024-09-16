//
//  LoginViewModel.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    
    @ObservedObject var loginManager = LoginManager.shared
    
    func loginWithEmail() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                LoginManager.saveUser(uid: result!.user.uid, email: self.email, password: self.password)
                self.errorMessage = nil
                self.loginManager.isLoggedIn = true
            }
        }
    }
}
