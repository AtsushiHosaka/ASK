//
//  QuestionsView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI

struct QuestionList: View {
    @EnvironmentObject var modelData: ModelData
    @State private var initialLoaded = false  // 新しい変数を追加して初回ロードを確認
    
    var body: some View {
        NavigationSplitView {
            if modelData.isLoading && !initialLoaded {  // 初回ロード時にのみ表示
                ProgressView("Loading...")  // ローディング中に表示
            } else {
                List {
                    ForEach(modelData.questions) { question in
                        if let _ = question.id {
                            NavigationLink {
                                MessageView(question: question)
                            } label: {
                                QuestionRow(question: question)
                            }
                        }
                    }
                }
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
            let newQuestion = Question(title: "わからない", createDate: Date(), memberID: [userId], messages: [])
            await modelData.addQuestion(newQuestion)
        }
    }
}

#Preview {
    QuestionList()
        .environmentObject(ModelData())
}
