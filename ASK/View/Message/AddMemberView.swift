//
//  AddMemberView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI

struct AddMemberView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = DataManager.shared
    
    @ObservedObject var viewModel = AddMemberViewModel()
    
    var question: Question
    
    var body: some View {
        VStack {
            Text("ユーザーを追加")
                .font(.custom("HelveticaNeue", size: 30))
                .fontWeight(.black)
                .foregroundStyle(.indigo)
            
            TextField("名前", text: $viewModel.searchText)
                .font(.custom("Helvetica Neue", size: 18))
                .padding(.bottom, 8)
                .background(Color.clear)
                .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: viewModel.searchText) {
                    Task {
                        await viewModel.fetchUsers(for: viewModel.searchText)
                    }
                }
            
            List(viewModel.users) { user in
                HStack {
                    UserIcon(user: user)
                    Text(user.name)
                        .font(.custom("HelveticaNeue", size: 16))
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .padding(.vertical)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                )
                .onTapGesture {
                    viewModel.selectedUser = user
                }
            }
            .scrollContentBackground(.hidden)
        }
        .padding()
        .onAppear {
            viewModel.dismiss = dismiss
        }
        .alert(item: $viewModel.selectedUser) { user in
            Alert(
                title: Text("ユーザーを追加"),
                message: Text("\(user.name)をチャットに追加しますか？"),
                primaryButton: .default(Text("追加")) {
                    viewModel.addUserToQuestion(questionId: question.id!, user: user)
                },
                secondaryButton: .cancel()
            )
        }
    }
}
