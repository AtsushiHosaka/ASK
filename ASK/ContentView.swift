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
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.white, .blue.opacity(0.2), .white, .purple.opacity(0.2), .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea(.all)
            
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                if loginManager.isLoggedIn {
                    MainView()
                } else {
                    LoginView()
                }
            }
        }
        .onAppear {
            viewModel.checkIfLoggedIn()
        }
    }
}
