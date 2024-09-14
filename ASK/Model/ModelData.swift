//
//  ModelData.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class ModelData: ObservableObject {
    @Published var users: [User] = []
    @Published var questions: [Question] = []
    @Published var isLoading = false
    
    private let firebaseAPI = FirebaseAPI()
    private var listener: ListenerRegistration?
    
    deinit {
        listener?.remove()
    }
    
    func addQuestionsListener() {
        guard let userId = UserPersistence.loadUserUID() else { return }
        self.isLoading = true  // ローディング状態を設定
        
        listener = Firestore.firestore().collection("questions")
            .whereField("memberID", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching questions: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false  // エラー時にローディングを終了
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No questions found")
                    DispatchQueue.main.async {
                        self.isLoading = false  // 質問が見つからない場合にローディングを終了
                    }
                    return
                }
                
                Task {
                    do {
                        var questions = documents.compactMap { document in
                            try? document.data(as: Question.self)
                        }
                        
                        // リアルタイムで質問ごとのユーザー情報を取得して代入
                        for index in questions.indices {
                            let questionMembers = try await self.firebaseAPI.fetchUsersByIds(ids: questions[index].memberID)
                            questions[index].member = questionMembers
                        }
                        
                        DispatchQueue.main.async {
                            self.questions = questions.sorted(by: { $0.createDate >= $1.createDate })
                            self.isLoading = false  // 質問取得後にローディングを終了
                        }
                    } catch {
                        print("Error fetching users for questions: \(error)")
                        DispatchQueue.main.async {
                            self.isLoading = false  // エラー時にローディングを終了
                        }
                    }
                }
            }
    }
    
    func loadQuestions() async {
        DispatchQueue.main.async {
            self.isLoading = true  // ローディング状態を設定
        }
        
        do {
            let fetchedQuestions = try await firebaseAPI.fetchQuestions()
            
            DispatchQueue.main.async {
                self.questions = fetchedQuestions.sorted(by: { $0.createDate >= $1.createDate })
                self.isLoading = false  // 質問取得後にローディングを終了
            }
        } catch {
            print("Error fetching questions: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false  // エラー時にローディングを終了
            }
        }
    }
    
    func loadUsers() async {
        DispatchQueue.main.async {
            self.isLoading = true  // ローディング状態を設定
        }
        
        do {
            guard let userId = UserPersistence.loadUserUID() else { return }
            let fetchedUsers = try await self.firebaseAPI.fetchUsersByIds(ids: [userId])
            
            DispatchQueue.main.async {
                self.users = fetchedUsers
                self.isLoading = false  // ユーザー取得後にローディングを終了
            }
        } catch {
            print("Error fetching users: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false  // エラー時にローディングを終了
            }
        }
    }
    
    func addQuestion(_ question: Question) async {
        DispatchQueue.main.async {
            self.isLoading = true  // ローディング状態を設定
        }
        
        do {
            try await firebaseAPI.addQuestion(question: question)
            
            DispatchQueue.main.async {
                self.isLoading = false  // 質問追加後にローディングを終了
            }
        } catch {
            print("Error adding question: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false  // エラー時にローディングを終了
            }
        }
    }
}
