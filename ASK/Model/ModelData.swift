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
    @Published var threads: [Question] = []  // スレッドを保持
    @Published var isLoading = false       // ローディング状態
    private var listener: ListenerRegistration?  // Firestoreリスナー
    
    init() {
        // Firestoreのリアルタイムリスナーを設定
        addThreadsListener()
    }
    
    deinit {
        // リスナーを解放
        listener?.remove()
    }
    
    // Firestoreからスレッドをリアルタイムで監視する関数
    private func addThreadsListener() {
        isLoading = true
        
        listener = Firestore.firestore().collection("threads").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching threads: \(error)")
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No threads found")
                self.isLoading = false
                return
            }
            
            // スレッドをデコードして@Published threadsに更新
            self.threads = documents.compactMap { document in
                try? document.data(as: Question.self)
            }
            self.isLoading = false
        }
    }
    
    // 手動でFirestoreからスレッドを取得する関数（必要に応じて使用）
    func loadThreads() async {
        do {
            isLoading = true
            let fetchedThreads = try await FirebaseAPI().fetchThreads()
            DispatchQueue.main.async {
                self.threads = fetchedThreads
                self.isLoading = false
            }
        } catch {
            print("Error fetching threads: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
