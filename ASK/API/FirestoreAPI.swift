//
//  FirestoreAPI.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import FirebaseFirestore
import FirebaseAuth

class FirestoreAPI {
    static private let db = Firestore.firestore()
    
    //MARK: Project-
    static func fetchProjects() async throws -> [Project] {
        guard let userId = LoginManager.loadUserUID() else {
            return []
        }
        
        let snapshot = try await db.collection("projects").whereField("memberIDList", arrayContains: userId).getDocuments()
        
        let firestoreProjects = try snapshot.documents.compactMap { try $0.data(as: FirestoreProject.self) }
        
        var projects: [Project] = []
        
        for firestoreProject in firestoreProjects {
            var project = Project(firestoreProject: firestoreProject)
            project.iconImage = await FirebaseStorageAPI.fetchImageData(from: firestoreProject.iconImageName)
            project.memberList = try await FirestoreAPI.fetchUsersByIds(ids: firestoreProject.memberIDList)
            project.threadList = try await FirestoreAPI.fetchThreadList(projectID: project.id)
            projects.append(project)
        }
        
        return projects
    }
    
    static func addProject(project: Project) async throws {
        let firestoreProject = FirestoreProject(project: project)
        
        try db.collection("projects").addDocument(from: firestoreProject)
    }
    
    //MARK: Thread-
    static func fetchThreadList(projectID: String) async throws -> [Thread] {
        let snapshot = try await db.collection("projects").document(projectID).collection("threadList").getDocuments()
        
        let firestoreThreadList = try snapshot.documents.compactMap { try $0.data(as: FirestoreThread.self) }
        
        var threadList: [Thread] = []
        
        for firestoreThread in firestoreThreadList {
            var thread = Thread(firestoreThread: firestoreThread)
            thread.chatMessages = try await fetchChatMessageList(projectID: projectID, threadID: thread.id)
            threadList.append(thread)
        }
        
        return threadList
    }
    
    //MARK: Message-
    static func addMessageToFirestore(projectID: String, threadID: String, message: Message) async throws {
        do {
            let firestoreMessage = FirestoreMessage(message: message)
            try db.collection("projects").document(projectID).collection("threadList").document(threadID).collection("messageList").addDocument(from: firestoreMessage)
        } catch {
            throw NSError(domain: "FirebaseAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to add message: \(error.localizedDescription)"])
        }
    }
    
    static private func fetchChatMessageList(projectID: String, threadID: String) async throws -> [Message] {
        let snapshot = try await db.collection("projects").document(projectID).collection("threadList").document(threadID).collection("messageList").getDocuments()
        
        let firestoreMessages = try snapshot.documents.compactMap { try $0.data(as: FirestoreMessage.self) }
        
        var messages: [Message] = []
        
        for firestoreMessage in firestoreMessages {
            var message = Message(firestoreMessage: firestoreMessage)
            message.sentUser = try await fetchUser(userID: message.sentBy)
            
            messages.append(message)
        }
        
        return messages
    }
    
    //MARK: User-
    static func searchUsers(for query: String) async throws -> [User] {
        let snapshot = try await db.collection("users")
            .whereField("name", isGreaterThanOrEqualTo: query)
            .whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments()
        
        var users = try snapshot.documents.compactMap { try $0.data(as: User.self) }
        
        for index in users.indices {
            users[index].imageData = await FirebaseStorageAPI.fetchImageData(from: users[index].imageName)
        }
        
        return users
    }
    
    static func fetchUser(userID: String) async throws -> User {
        let snapshot = try await db.collection("users").document(userID).getDocument()
        
        var user = try snapshot.data(as: User.self)
        
        user.imageData = await FirebaseStorageAPI.fetchImageData(from: user.imageName)
        
        return user
    }
    
    static func fetchUsersByIds(ids: [String]) async throws -> [User] {
        var users: [User] = []
        
        for id in ids {
            do {
                let userDocument = try await db.collection("users").document(id).getDocument()
                
                if var user = try? userDocument.data(as: User.self) {
                    user.imageData = await FirebaseStorageAPI.fetchImageData(from: user.imageName)
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
    
    static func saveUserToFirestore(uid: String, name: String, imageName: String?) async {
        let user = User(id: uid, name: name, imageName: imageName ?? "")
        
        do {
            try db.collection("users").document(uid).setData(from: user)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func addUserToProject(projectID: String, user: User) async throws {
        let document = db.collection("projects").document(projectID)
        do {
            try await document.updateData([
                "memberIDList": FieldValue.arrayUnion([user.id!])
            ])
        } catch {
            throw error
        }
    }
    
//    static func fetchQuestions() async throws -> [Question] {
//        guard let userId = LoginManager.loadUserUID() else {
//            return []
//        }
//        
//        let snapshot = try await db.collection("questions").whereField("memberID", arrayContains: userId).order(by: "createDate", descending: true).getDocuments()
//        
//        var questions = try snapshot.documents.compactMap { try $0.data(as: Question.self) }
//        
//        for index in questions.indices {
//            questions[index].member = try await fetchUsersByIds(ids: questions[index].memberID)
//            questions[index].messages = try await fetchMessages(of: questions[index].id!)
//        }
//        
//        return questions
//    }
    
//    static func addQuestion(question: Question) async throws {
//        do {
//            var firestoreQuestion = question
//            firestoreQuestion.messages = nil
//            
//            try db.collection("questions").document(question.id ?? UUID().uuidString).setData(from: firestoreQuestion)
//            
//            if let messages = question.messages {
//                for message in messages {
//                    try await addMessageToFirestore(question: question, message: message)
//                }
//            }
//            
//        } catch {
//            throw NSError(domain: "FirebaseAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to add question: \(error.localizedDescription)"])
//        }
//    }
    
//    static private func fetchMessages(of questionID: String) async throws -> [Message] {
//        let snapshot = try await db.collection("questions").document(questionID).collection("messages").order(by: "date").getDocuments()
//        
//        let firestoreMessages = try snapshot.documents.compactMap { try $0.data(as: FirestoreMessage.self) }
//        
//        var messages: [Message] = []
//        
//        for firestoreMessage in firestoreMessages {
//            var message = Message(firestoreMessage: firestoreMessage)
//            message.sentUser = try await fetchUser(userID: message.sentBy)
//            
//            messages.append(message)
//        }
//        
//        return messages
//    }
}
