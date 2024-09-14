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
            QuestionList()
                .frame(minWidth: 800, minHeight: 600)
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
    
    init() {
        checkIfLoggedIn()
    }
    
    private func checkIfLoggedIn() {
        if let currentUser = Auth.auth().currentUser {
            isLoggedIn = true
        }
    }
}

#Preview {
    ContentView()
}
