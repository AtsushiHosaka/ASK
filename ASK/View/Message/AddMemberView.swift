//
//  AddMemberView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI

import SwiftUI
import FirebaseFirestore

import SwiftUI
import FirebaseFirestore

import SwiftUI
import FirebaseFirestore

struct AddMemberView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @State private var users: [User] = []
    @State private var selectedUser: User? = nil
    @EnvironmentObject var modelData: ModelData
    var question: Question
    
    var body: some View {
        VStack {
            Text("ユーザーを追加")
                .font(.custom("HelveticaNeue", size: 30))
                .fontWeight(.black)
                .foregroundStyle(.indigo)
            
            TextField("Search Users", text: $searchText)
                .font(.custom("Helvetica Neue", size: 18))
                .padding(.bottom, 8)
                .background(Color.clear)
                .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: searchText) {
                    fetchUsers(for: searchText)
                }
            
            List(users) { user in
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
                    selectedUser = user
                }
            }
            .scrollContentBackground(.hidden)
        }
        .padding()
        .alert(item: $selectedUser) { user in
            Alert(
                title: Text("Add User"),
                message: Text("Do you want to add \(user.name)?"),
                primaryButton: .default(Text("Add")) {
                    addUserToQuestion(user)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func fetchUsers(for query: String) {
        // Fetch users from Firestore based on the search query
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("name", isGreaterThanOrEqualTo: query)
            .whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching users: \(error)")
                } else {
                    users = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: User.self)
                    } ?? []
                }
            }
    }
    
    private func addUserToQuestion(_ user: User) {
        // Add user to the question's members in Firestore
        let db = Firestore.firestore()
        db.collection("questions").document(question.id!)
            .updateData([
                "memberID": FieldValue.arrayUnion([user.id!])
            ]) { error in
                if let error = error {
                    print("Error updating question: \(error)")
                } else {
                    dismiss()
                }
            }
    }
}
