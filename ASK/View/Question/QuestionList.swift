//
//  QuestionsView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI

struct QuestionList: View {
    @EnvironmentObject var modelData: ModelData  // ModelDataを@EnvironmentObjectで参照
    
    var body: some View {
        NavigationSplitView {
            if modelData.isLoading {
                ProgressView("Loading...")  // ローディング中に表示
            } else {
                List {
                    ForEach(modelData.questions) { question in
                        if let questionId = question.id {  // Questionのidをアンラップ
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
                    Task {
                        // 初回表示時にスレッドのリスナーがセットされていることを確認
                        if modelData.questions.isEmpty {
                            await modelData.loadQuestions()
                        }
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func addQuestion() {
        Task {
            let newQuestion = Question(title: "わからない", createDate: Date(), memberID: ["as"])
            await modelData.addQuestion(newQuestion)
        }
    }
}

#Preview {
    QuestionList()
        .environmentObject(ModelData())
}
