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
    
    @State private var showingAlert = false
    
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
