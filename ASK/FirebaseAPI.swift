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
    
    // 現在ログインしているユーザーのIDがmemberIDに含まれているQuestionsを取得し、各Questionのmemberに該当するUserを代入
    func fetchQuestions() async throws -> [Question] {
        // ログインユーザーを取得
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let userId = currentUser.uid
        
        // FirestoreからQuestionsを取得
        let snapshot = try await db.collection("threads").getDocuments()
        
        // フィルタリングしてログインしているユーザーが含まれているスレッドだけ返す
        var questions = try snapshot.documents.compactMap { document -> Question? in
            let question = try document.data(as: Question.self)
            return question.memberID.contains(userId) ? question : nil
        }
        
        // memberIDに一致するユーザーを取得してmemberに代入
        for index in questions.indices {
            do {
                let questionMembers = try await fetchUsersByIds(ids: questions[index].memberID)
                questions[index].member = questionMembers
            } catch {
                print("Failed to fetch members for question \(questions[index].id ?? ""): \(error.localizedDescription)")
                questions[index].member = []
            }
        }
        
        return questions
    }
    
    // ユーザーをIDから取得する関数
    private func fetchUsersByIds(ids: [String]) async throws -> [User] {
        var users: [User] = []
        
        for id in ids {
            do {
                let userDocument = try await db.collection("users").document(id).getDocument()
                
                if let user = try? userDocument.data(as: User.self) {
                    users.append(user)
                } else {
                    // ユーザーが存在しない場合の処理
                    print("User with ID \(id) not found in database")
                }
            } catch {
                // ユーザー取得に失敗した場合はログ出力のみ
                print("Failed to fetch user with ID \(id): \(error.localizedDescription)")
            }
        }
        
        return users
    }
}
