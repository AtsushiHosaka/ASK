//
//  FirebaseAPI.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import FirebaseFirestore
import FirebaseAuth

class FirebaseAPI {
    private let db = Firestore.firestore()
    
    // 現在ログインしているユーザーのIDがmemberに含まれているThreadsを取得
    func fetchThreads() async throws -> [Thread] {
        // ログインユーザーを取得
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        guard let userId = UUID(uuidString: currentUser.uid) else {
            throw NSError(domain: "FirebaseAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to read UserID"])
        }

        // FirestoreからThreadsを取得
        let snapshot = try await db.collection("threads").getDocuments()
        
        // フィルタリングしてログインしているユーザーが含まれているスレッドだけ返す
        let threads = try snapshot.documents.compactMap { document -> Thread? in
            let thread = try document.data(as: Thread.self)
            return thread.member.contains(userId) ? thread : nil
        }
        
        return threads
    }
}
