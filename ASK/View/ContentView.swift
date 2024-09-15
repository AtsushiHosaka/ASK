//
//  ContentView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            QuestionList(isLoggedIn: $isLoggedIn)
                .frame(minWidth: 800, minHeight: 600)
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
                .onAppear {
                    checkIfLoggedIn()
                }
        }
    }
    
    private func checkIfLoggedIn() {
        if let email = UserPersistence.loadUserEmail(), 
           let password = UserPersistence.loadUserPassword() {
            
            loginWithEmail(email: email, password: password)
        }
    }
    
    func loginWithEmail(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.isLoggedIn = true
            }
        }
    }
}

#Preview {
    ContentView()
}
