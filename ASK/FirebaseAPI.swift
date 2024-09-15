//
//  FirebaseAPI.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseAPI {
    static private let db = Firestore.firestore()
    private let db = Firestore.firestore()
    
    func fetchQuestions() async throws -> [Question] {
        // ログインユーザーを取得します。
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let userId = currentUser.uid
        
        let snapshot = try await db.collection("questions").whereField("memberID", arrayContains: userId).order(by: "createDate", descending: true).getDocuments()
        
        var questions = try snapshot.documents.compactMap { try $0.data(as: Question.self) }
        
        for index in questions.indices {
            questions[index].member = try await fetchUsersByIds(ids: questions[index].memberID)
            questions[index].messages = try await loadMessages(of: questions[index].id!)
        }
        
        return questions
    }
    
    // ユーザーをIDから取得する関数
    func fetchUsersByIds(ids: [String]) async throws -> [User] {
        var users: [User] = []
        
        for id in ids {
            do {
                let userDocument = try await db.collection("users").document(id).getDocument()
                
                if var user = try? userDocument.data(as: User.self) {
                    user.imageData = await fetchImageData(from: user.imageName)
                    users.append(user)
                } else {
                    print("User with ID \(id) not found in database")
                }
            } catch {
                print("Failed to fetch user with ID \(id): \(error.localizedDescription)")
            }
        }
        
        return users
    }
    
    func fetchImageData(from imageName: String) async -> Data? {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(imageName)")
        
        // Download the image data
        do {
            let imageData = try await storageRef.data(maxSize: 5 * 1024 * 1024) // Limit to 5MB
            
            return imageData
        } catch {
            return nil
        }
    }
    
    private func loadMessages(of questionID: String) async throws -> [Message] {
        let snapshot = try await db.collection("questions").document(questionID).collection("messages").order(by: "date").getDocuments()
        
        let messages = try snapshot.documents.compactMap { try $0.data(as: Message.self) }
        
        return messages
    }
    
    static func addQuestion(question: Question) async throws {
        do {
            var firestoreQuestion = question
            firestoreQuestion.messages = nil
            
            try db.collection("questions").document(question.id ?? UUID().uuidString).setData(from: firestoreQuestion)
            
            // メッセージが存在する場合、各メッセージをFirestoreに追加
            if let messages = question.messages {
                for message in messages {
                    try await addMessageToFirestore(question: question, message: message)
                }
            }
            
        } catch {
            // エラー発生時にカスタムエラーをスロー
            throw NSError(domain: "FirebaseAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to add question: \(error.localizedDescription)"])
        }
    }

    static func addMessageToFirestore(question: Question, message: Message) async throws {
        guard let questionID = question.id else {
            // questionIDがnilの場合エラーをスロー
            throw NSError(domain: "FirebaseAPI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid question ID"])
        }
        
        let db = Firestore.firestore()
        let questionRef = db.collection("questions").document(questionID)
        
        do {
            // メッセージをFirestoreに追加
            try questionRef.collection("messages").addDocument(from: message)
        } catch {
            // メッセージ追加に失敗した場合にエラーをスロー
            throw NSError(domain: "FirebaseAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to add message: \(error.localizedDescription)"])
        }
    }
}
