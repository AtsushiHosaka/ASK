//
//  DataManager.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class DataManager: ObservableObject {
    static var shared = DataManager()
    
    @Published var users: [User] = []
    @Published var questions: [Question] = []
    @Published var isLoading = false
    
    private var listener: ListenerRegistration?
    private var messageListeners: [String: ListenerRegistration] = [:]
    
    deinit {
        listener?.remove()
        messageListeners.values.forEach { $0.remove() }
    }
    
    func addQuestionsListener() {
        guard let userId = LoginManager.loadUserUID() else { return }
        self.isLoading = true
        
        listener = Firestore.firestore().collection("questions")
            .whereField("memberID", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
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
                        var questions = documents.compactMap { document in
                            try? document.data(as: Question.self)
                        }
                        
                        for index in questions.indices {
                            let questionMembers = try await FirestoreAPI.fetchUsersByIds(ids: questions[index].memberID)
                            questions[index].member = questionMembers
                            
                            self.addMessagesListener(for: questions[index].id ?? "")
                        }
                        
                        let newQuestions = questions
                        
                        DispatchQueue.main.async {
                            self.questions = newQuestions
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
    
    func addMessagesListener(for questionID: String) {
        let db = Firestore.firestore()
        let messagesRef = db.collection("questions").document(questionID).collection("messages").order(by: "date")
        
        messageListeners[questionID]?.remove()
        
        let listener = messagesRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching messages: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No messages found")
                return
            }
            
            var updatedMessages: [Message] = []
            for document in documents {
                if let message = try? document.data(as: Message.self) {
                    updatedMessages.append(message)
                }
            }
            
            DispatchQueue.main.async {
                if let index = self.questions.firstIndex(where: { $0.id == questionID }) {
                    self.questions[index].messages = updatedMessages
                }
            }
        }
        
        messageListeners[questionID] = listener
    }
    
    func loadQuestions() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let fetchedQuestions = try await FirestoreAPI.fetchQuestions()
            
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
    
    func loadUsers() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            guard let userId = LoginManager.loadUserUID() else { return }
            let fetchedUsers = try await FirestoreAPI.fetchUsersByIds(ids: [userId])
            
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
            try await FirestoreAPI.addQuestion(question: question)
            
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
