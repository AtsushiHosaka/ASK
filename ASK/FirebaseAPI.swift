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
        // ログインユーザーを取得します。
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let userId = currentUser.uid
        
        let snapshot = try await db.collection("questions").whereField("memberID", arrayContains: userId).getDocuments()
        
        // フィルタリングしてログインしているユーザーが含まれているスレッドだけ返す
        var questions = try snapshot.documents.compactMap { try $0.data(as: Question.self) }
        
        for index in questions.indices {
            let questionMembers = try await fetchUsersByIds(ids: questions[index].memberID)
            questions[index].member = questionMembers
        }
        
        return questions
    }
    
    // ユーザーをIDから取得する関数
    func fetchUsersByIds(ids: [String]) async throws -> [User] {
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
    
    func addQuestion(question: Question) async throws {
        do {
            // Firestoreに質問を追加
            let _ = try db.collection("questions").addDocument(from: question)
        } catch {
            throw NSError(domain: "FirebaseAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to add question: \(error.localizedDescription)"])
        }
    }
    
    static func addMessageToFirestore(question: Question, message: Message) {
        guard let questionID = question.id else { return }
        let db = Firestore.firestore()
        let questionRef = db.collection("questions").document(questionID)
        
        do {
            try questionRef.collection("messages").addDocument(from: message)
        } catch let error {
            print("Error adding message to Firestore: \(error)")
        }
    }
}
