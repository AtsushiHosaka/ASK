//
//  QuestionListModel.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI
import FirebaseAuth

class QuestionListModel: ObservableObject {
    @Published var initialLoaded = false
    
    @ObservedObject var dataManager = DataManager.shared
    
    func addQuestion() {
        guard let userId = LoginManager.loadUserUID() else { return }
        
        Task {
            let newQuestion = Question(title: "わからない", createDate: Date(), memberID: [userId], messages: [Message(date: Date(), content: "質問を開始しました", sentBy: userId)])
            await dataManager.addQuestion(newQuestion)
            await dataManager.loadQuestions()
        }
    }
}
