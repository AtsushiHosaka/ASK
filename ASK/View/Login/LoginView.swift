//
//  LoginView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Spacer()
                
                Text("ASK")
                    .font(.custom("HelveticaNeue", size: 60))
                    .fontWeight(.heavy)
                    .foregroundStyle(.indigo)
                
                Spacer()
                
                AuthTextField(title: "メールアドレス", text: $email)
                
                AuthSecureField(title: "パスワード", text: $password)
                
                Button {
                    loginWithEmail()
                } label: {
                    AuthButton(icon: "envelope", text: "ログイン")
                        .frame(maxWidth: 300)
                }
                .buttonStyle(ClearBackgroundButtonStyle())
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                NavigationLink {
                    SignupView(isLoggedIn: $isLoggedIn)
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
        .background(Color.clear)
    }
    
    func loginWithEmail() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                UserPersistence.saveUser(uid: result!.user.uid, email: email, password: password)
                self.errorMessage = nil
                self.isLoggedIn = true
            }
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
