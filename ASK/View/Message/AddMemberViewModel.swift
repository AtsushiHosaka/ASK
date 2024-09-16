//
//  AddMemberViewModel.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import Foundation
import SwiftUI

class AddMemberViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var users: [User] = []
    @Published var selectedUser: User? = nil
    
    var dismiss: DismissAction?
    
    func fetchUsers(for query: String) async {
        do {
            users = try await FirestoreAPI.fetchUsers(for: query)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addUserToQuestion(questionId: String, user: User) {
        Task {
            do {
                try await FirestoreAPI.addUserToQuestion(questionId: questionId, user: user)
                dismiss?()  // 成功時に画面を閉じる
            } catch {
                print(error.localizedDescription)  // エラーをログに表示
            }
        }
    }
}
