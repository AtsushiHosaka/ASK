//
//  QuestionsView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import FirebaseAuth

struct QuestionList: View {
    @EnvironmentObject var modelData: ModelData
    @State private var initialLoaded = false  // 新しい変数を追加して初回ロードを確認
    @Binding var isLoggedIn: Bool  // ログイン状態をバインディング
    
    var body: some View {
        NavigationSplitView {
            if modelData.isLoading && !initialLoaded {  // 初回ロード時にのみ表示
                ProgressView("Loading...")  // ローディング中に表示
            } else {
                List {
                    ForEach(modelData.questions) { question in
                        if let _ = question.id {
                            NavigationLink {
                                ChatView(question: question)
                            } label: {
                                QuestionRow(question: question)
                            }
                        }
                    }
                }
                Spacer()
                Button("Logout", action: logout)
                
                .toolbar {
                    ToolbarItem {
                        Button(action: addQuestion) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                .onAppear {
                    if !initialLoaded {
                        Task {
                            if modelData.questions.isEmpty {
                                modelData.addQuestionsListener()
                                await modelData.loadQuestions()
                                initialLoaded = true  // 初回ロード完了を設定
                            }
                        }
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func addQuestion() {
        guard let userId = UserPersistence.loadUserUID() else { return }
        
        Task {
            let title = "わからない"
            let newQuestion = Question(title: title, createDate: Date(), memberID: [userId], messages: [Message(date: Date(), content: "\(title)を開始しました", sentBy: userId)])
            await modelData.addQuestion(newQuestion)
            await modelData.loadQuestions()
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            UserPersistence.clearUser()
            isLoggedIn = false  // ログアウト後にログイン画面を表示
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
