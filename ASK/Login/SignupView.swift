//
//  SignupView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI

struct SignupView: View {
    @ObservedObject var loginManager = LoginManager.shared
    @ObservedObject var viewModel = SignupViewModel()
    
    

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Spacer()
            
            Text("ASK")
                .font(.custom("HelveticaNeue", size: 60))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
            
            Spacer()
            
            AuthTextField(title: "名前", text: $viewModel.name)
            
            AuthTextField(title: "メールアドレス", text: $viewModel.email)
            
            AuthSecureField(title: "パスワード", text: $viewModel.password)
            
            AuthSecureField(title: "パスワード確認", text: $viewModel.passwordConfirmation)
            
            Button {
                viewModel.selectImage()
            } label: {
                if let selectedImage = viewModel.selectedImage {
                    Image(nsImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                }
            }
            .buttonStyle(ClearBackgroundButtonStyle())
            
            Text("アイコンを選択")
                .font(.custom("HelveticaNeue", size: 16))
                .foregroundStyle(.secondary)
                .padding(.top, -20)
            
            Button {
                viewModel.checkSignup()
            } label: {
                AuthButton(icon: "envelope", text: "アカウント作成")
                    .frame(maxWidth: 300)
            }
            .buttonStyle(ClearBackgroundButtonStyle())
            
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}
