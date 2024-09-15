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
            TextField("Search Users", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText) {
                    fetchUsers(for: searchText)
                }
            
            List(users) { user in
                Text(user.name)
                    .onTapGesture {
                        selectedUser = user
                    }
            }
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
                }
            }
    }
}
