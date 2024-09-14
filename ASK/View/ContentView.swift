//
//  ContentView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            QuestionList()
                .frame(minWidth: 800, minHeight: 600)
        } else {
            LoginView()
        }
    }
    
    init() {
        checkIfLoggedIn()
    }
    
    private func checkIfLoggedIn() {
        if let currentUser = Auth.auth().currentUser {
            // すでにログインしているユーザーがいる場合
            let user = User(email: currentUser.email ?? "", isLoggedIn: true)
            modelContext.insert(user)
            isLoggedIn = true
        }
    }
}

#Preview {
    ContentView()
}
