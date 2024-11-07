//
//  LoginView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @ObservedObject var loginManager = LoginManager.shared
    @ObservedObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, .blue.opacity(0.2), .white, .purple.opacity(0.2), .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    Spacer()
                    
                    Text("ASK")
                        .font(.custom("HelveticaNeue", size: 60))
                        .fontWeight(.heavy)
                        .foregroundStyle(.indigo)
                    
                    Spacer()
                    
                    AuthTextField(title: "メールアドレス", text: $viewModel.email)
                    
                    AuthSecureField(title: "パスワード", text: $viewModel.password)
                    
                    Button {
                        viewModel.loginWithEmail()
                    } label: {
                        AuthButton(icon: "envelope", text: "ログイン")
                            .frame(maxWidth: 300)
                    }
                    .buttonStyle(ClearBackgroundButtonStyle())
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    NavigationLink {
                        SignupView()
                    } label: {
                        AuthButton(icon: "envelope", text: "登録")
                            .frame(maxWidth: 300)
                    }
                    .navigationTitle("アカウント作成")
                    .buttonStyle(ClearBackgroundButtonStyle())
                    
                    Spacer()
                    Spacer()
                }
            }
        }
    }
}
