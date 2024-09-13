//
//  ModelData.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import Combine
import FirebaseFirestore

class ModelData: ObservableObject {
    @Published var users: [User] = []
    @Published var questions: [Question] = []
    @Published var isLoading = false       // ローディング状態
    private var listener: ListenerRegistration?  // Firestoreリスナー
    
    init() {
        // Firestoreのリアルタイムリスナーを設定
        addQuestionsListener()
    }
    
    deinit {
        // リスナーを解放
        listener?.remove()
    }
    
    // Firestoreからスレッドをリアルタイムで監視する関数
    private func addQuestionsListener() {
        isLoading = true
        
        listener = Firestore.firestore().collection("questions").whereField("memberID", arrayContains: "as").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching questions: \(error)")
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No questions found")
                self.isLoading = false
                return
            }
            
            Task {
                do {
                    // Firestoreからリアルタイムで質問をデコードする
                    var questions = documents.compactMap { document in
                        try? document.data(as: Question.self)
                    }
                    
                    // リアルタイムで質問ごとのユーザー情報を取得して代入
                    for index in questions.indices {
                        let questionMembers = try await FirebaseAPI().fetchUsersByIds(ids: questions[index].memberID)
                        questions[index].member = questionMembers
                    }
                    
                    // @Published propertyを更新
                    DispatchQueue.main.async {
                        self.questions = questions
                        self.isLoading = false
                    }
                } catch {
                    print("Error fetching users for questions: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    // 手動でFirestoreからスレッドを取得する関数（必要に応じて使用）
    func loadQuestions() async {
        do {
            isLoading = true
            let fetchedQuestions = try await FirebaseAPI().fetchQuestions()
            
            // Fetch users for questions in parallel
            var updatedQuestions = fetchedQuestions
            for index in updatedQuestions.indices {
                let questionMembers = try await FirebaseAPI().fetchUsersByIds(ids: updatedQuestions[index].memberID)
                updatedQuestions[index].member = questionMembers
            }
            
            DispatchQueue.main.async {
                self.questions = updatedQuestions
                self.isLoading = false
            }
        } catch {
            print("Error fetching questions: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func loadUsers() async {
        do {
            isLoading = true
            let fetchedUsers = try await FirebaseAPI().fetchUsersByIds(ids: ["as"])
            DispatchQueue.main.async {
                self.users = fetchedUsers
                self.isLoading = false
            }
        } catch {
            print("Error fetching users: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
