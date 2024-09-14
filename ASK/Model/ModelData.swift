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
    
    private let firebaseAPI = FirebaseAPI()
    private var listener: ListenerRegistration?  // Firestoreリスナー
    
    init() {
        // Firestoreのリアルタイムリスナーを設定
        addQuestionsListener()
    }
    
    deinit {
        // リスナーを解放
        listener?.remove()
    }
    
    private func addQuestionsListener() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        listener = Firestore.firestore().collection("questions").whereField("memberID", arrayContains: "as").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching questions: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No questions found")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
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
                        let questionMembers = try await self.firebaseAPI.fetchUsersByIds(ids: questions[index].memberID)
                        questions[index].member = questionMembers
                    }
                    
                    // @Publishedプロパティをメインスレッドで更新
                    DispatchQueue.main.async {
                        self.questions = questions.sorted(by: { $0.createDate >= $1.createDate })
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
    
    func loadQuestions() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let fetchedQuestions = try await firebaseAPI.fetchQuestions()
            
            DispatchQueue.main.async {
                self.questions = fetchedQuestions.sorted(by: { $0.createDate >= $1.createDate })
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
            let fetchedUsers = try await self.firebaseAPI.fetchUsersByIds(ids: ["as"])
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
    
    func addQuestion(_ question: Question) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            // FirebaseAPIのaddQuestionメソッドを呼び出してFirestoreに追加
            try await firebaseAPI.addQuestion(question: question)
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            print("Error adding question: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
