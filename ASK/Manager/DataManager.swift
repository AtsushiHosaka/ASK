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
    
    @Published var isLoading = false
    
    @Published var projects: [Project] = []
    
    private var listener: ListenerRegistration?
    private var threadListeners: [String: ListenerRegistration] = [:]
    private var messageListeners: [String: ListenerRegistration] = [:]
    
    deinit {
        listener?.remove()
        threadListeners.values.forEach { $0.remove() }
        messageListeners.values.forEach { $0.remove() }
    }
    
    func isListeningThreadList(ofProjectID projectID: String) -> Bool {
        return threadListeners[projectID] != nil
    }
    
    func addProjectsListener() async {
        guard let userId = LoginManager.loadUserUID() else { return }
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        listener = Firestore.firestore().collection("projects").whereField("memberIDList", arrayContains: userId).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching projects: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No projects found")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            Task {
                do {
                    let projects = documents.compactMap { document in
                        try? document.data(as: FirestoreProject.self)
                    }
                    
                    var fetchedProjects: [Project] = []
                    
                    for firestoreProject in projects {
                        var project = Project(firestoreProject: firestoreProject)
                        
                        project.iconImage = await FirebaseStorageAPI.fetchImageData(from: project.iconImageName)
                        
                        // メンバー情報の取得
                        let members = try await FirestoreAPI.fetchUsersByIds(ids: firestoreProject.memberIDList)
                        project.memberList = members
                        
                        project.threadList = try await FirestoreAPI.fetchThreadList(projectID: firestoreProject.id!)
                        
                        fetchedProjects.append(project)
                    }
                    
                    DispatchQueue.main.async {
                        self.projects = fetchedProjects
                    }
                    
                    for project in fetchedProjects {
                        await self.addThreadsListener(for: project.id)
                    }
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                } catch {
                    print("Error fetching users for projects: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    func addThreadsListener(for projectID: String) async {
        threadListeners[projectID]?.remove()
        
        let listener = Firestore.firestore()
            .collection("projects")
            .document(projectID)
            .collection("threadList")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching threads: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No threads found")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                Task {
                    do {
                        let firestoreThreads = try documents.compactMap { try $0.data(as: FirestoreThread.self) }
                        var updatedThreads: [Thread] = []
                        
                        for firestoreThread in firestoreThreads {
                            let thread = Thread(firestoreThread: firestoreThread)
                            updatedThreads.append(thread)
                        }
                        
                        DispatchQueue.main.async {
                            if let index = self.projects.firstIndex(where: { $0.id == projectID }) {
                                self.projects[index].threadList = updatedThreads
                            }
                        }
                        
                        for thread in updatedThreads {
                            await self.addMessagesListener(projectID: projectID, threadID: thread.id)
                        }
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                        }
                    } catch {
                        print("Error processing threads: \(error)")
                        DispatchQueue.main.async {
                            self.isLoading = false
                        }
                    }
                }
            }
        
        threadListeners[projectID] = listener
    }
    
    func addMessagesListener(projectID: String, threadID: String) async {
        let listenerKey = "\(projectID)_\(threadID)"
        if let listener = messageListeners[listenerKey] {
            listener.remove()
        }
        
        let listener = Firestore.firestore()
            .collection("projects")
            .document(projectID)
            .collection("threadList")
            .document(threadID)
            .collection("messageList")
            .order(by: "date")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching messages: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No messages found")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                Task {
                    do {
                        var messages: [Message] = []
                        for document in documents {
                            if let message = try? document.data(as: FirestoreMessage.self) {
                                var updatedMessage = Message(firestoreMessage: message)
                                if let index = self.projects.firstIndex(where: { $0.id == projectID }),
                                   let sentUser = self.projects[index].memberList.first(where: { $0.id == message.sentBy }) {
                                    updatedMessage.sentUser = sentUser
                                } else {
                                    updatedMessage.sentUser = try await FirestoreAPI.fetchUser(userID: message.sentBy)
                                }
                                messages.append(updatedMessage)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if let projectIndex = self.projects.firstIndex(where: { $0.id == projectID }),
                               let threadIndex = self.projects[projectIndex].threadList.firstIndex(where: { $0.id == threadID }) {
                                self.projects[projectIndex].threadList[threadIndex].chatMessages = messages
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                        }
                    } catch {
                        print("Error processing messages: \(error)")
                        DispatchQueue.main.async {
                            self.isLoading = false
                        }
                    }
                }
            }
        
        messageListeners[listenerKey] = listener
    }
    
    func removeThreadListener(for projectID: String) {
        threadListeners[projectID]?.remove()
        threadListeners.removeValue(forKey: projectID)
    }
    
    func removeMessageListener(projectID: String, threadID: String) {
        let listenerKey = "\(projectID)_\(threadID)"
        messageListeners[listenerKey]?.remove()
        messageListeners.removeValue(forKey: listenerKey)
    }
    
    func fetchProjects() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let projects = try await FirestoreAPI.fetchProjects()
            
            DispatchQueue.main.async {
                self.projects = projects
                self.isLoading = false
            }
        } catch {
            print("Error fetching projects: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
//    func addQuestion(_ question: Question) async {
//        DispatchQueue.main.async {
//            self.isLoading = true
//        }
//        
//        do {
//            try await FirestoreAPI.addQuestion(question: question)
//            
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//        } catch {
//            print("Error adding question: \(error)")
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//        }
//    }
}
