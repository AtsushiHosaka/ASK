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
    
    // 現在ログインしているユーザーのIDがmemberIDに含まれているThreadsを取得し、各Threadのmemberに該当するUserを代入
    func fetchThreads() async throws -> [Question] {
        // ログインユーザーを取得
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let userId = currentUser.uid
        
        // FirestoreからThreadsを取得
        let snapshot = try await db.collection("threads").getDocuments()
        
        // フィルタリングしてログインしているユーザーが含まれているスレッドだけ返す
        var threads = try snapshot.documents.compactMap { document -> Question? in
            let thread = try document.data(as: Question.self)
            return thread.memberID.contains(userId) ? thread : nil
        }
        
        // memberIDに一致するユーザーを取得してmemberに代入
        for index in threads.indices {
            print(index)
            let threadMembers = try await fetchUsersByIds(ids: threads[index].memberID)
            threads[index].member = threadMembers
        }
        
        return threads
    }
    
    // ユーザーをIDから取得する関数
    private func fetchUsersByIds(ids: [String]) async throws -> [User] {
        var users: [User] = []
        
        for id in ids {
            do {
                let userDocument = try await db.collection("users").document(id).getDocument()
                
                let user = try userDocument.data(as: User.self)
                
                users.append(user)
            } catch {
                // ユーザー取得に失敗した場合はスキップ
                print("Failed to fetch user with ID \(id): \(error.localizedDescription)")
            }
        }
        
        return users
    }
}
