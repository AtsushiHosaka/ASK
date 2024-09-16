//
//  QuestionsView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import FirebaseAuth

struct QuestionList: View {
    @ObservedObject var dataManager = DataManager.shared
    @ObservedObject var loginManager = LoginManager.shared
    
    @State private var initialLoaded = false
    @State private var showingAlert = false
    
    var body: some View {
        NavigationSplitView {
            if dataManager.isLoading && !initialLoaded {
                ProgressView("Loading...")
            } else {
                List {
                    ForEach(dataManager.questions) { question in
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
                
                    .toolbar {
                        ToolbarItem {
                            Button(action: addQuestion) {
                                Label("Add Item", systemImage: "plus")
                            }
                        }
                        ToolbarItem {
                            Button{
                                showingAlert = true
                            } label: {
                                Label("logout", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                            .alert(isPresented: $showingAlert) {
                                Alert(
                                    title: Text("ログアウトしますか？"),
                                    primaryButton: .destructive(Text("ログアウト")) {
                                        logout()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                    }
                    .onAppear {
                        if !initialLoaded {
                            Task {
                                if dataManager.questions.isEmpty {
                                    dataManager.addQuestionsListener()
                                    await dataManager.loadQuestions()
                                    initialLoaded = true
                                }
                            }
                        }
                    }
            }
        } detail: {
            VStack {
                Text("ASK")
                    .font(.custom("HelveticaNeue", size: 60))
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                Text("チャットを選択")
                    .font(.custom("HelveticaNeue", size: 16))
                    .foregroundStyle(.white)
            }
            .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 8, x: 0, y: 0)
        }
    }
    
    private func addQuestion() {
        guard let userId = LoginManager.loadUserUID() else { return }
        
        Task {
            let title = "わからない"
            let newQuestion = Question(title: title, createDate: Date(), memberID: [userId], messages: [Message(date: Date(), content: "\(title)を開始しました", sentBy: userId)])
            await dataManager.addQuestion(newQuestion)
            await dataManager.loadQuestions()
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            LoginManager.clearUser()
            loginManager.isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}