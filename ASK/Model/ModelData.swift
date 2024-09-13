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
        
        listener = Firestore.firestore().collection("questions").addSnapshotListener { snapshot, error in
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
            
            // スレッドをデコードして@Published questionsに更新
            self.questions = documents.compactMap { document in
                try? document.data(as: Question.self)
            }
            self.isLoading = false
        }
    }
    
    // 手動でFirestoreからスレッドを取得する関数（必要に応じて使用）
    func loadQuestions() async {
        do {
            isLoading = true
            let fetchedQuestions = try await FirebaseAPI().fetchQuestions()
            DispatchQueue.main.async {
                self.questions = fetchedQuestions
                self.isLoading = false
            }
        } catch {
            print("Error fetching questions: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
