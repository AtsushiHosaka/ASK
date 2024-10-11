//
//  ContentView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @ObservedObject var loginManager = LoginManager.shared
    @ObservedObject var viewModel = ContentViewModel()
    
    var body: some View {
        if loginManager.isLoggedIn {
            QuestionList()
                .frame(minWidth: 800, minHeight: 600)
        } else {
            LoginView()
                .onAppear {
                    viewModel.checkIfLoggedIn()
                }
        }
    }
    
    
}

#Preview {
    ContentView()
}
