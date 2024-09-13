//
//  MessageView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI

struct MessageView: View {
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
                                VStack(alignment: .leading) {
                                    Text("Question: \(question.title)")
                                        .font(.headline)
                                    Text("Created on: \(question.createDate, formatter: dateFormatter)")
                                        .font(.subheadline)
                                    
                                    if let member = question.member {
                                        ForEach(member) { user in
                                            if let userId = user.id {  // Userのidをアンラップ
                                                HStack {
                                                    Text("User: \(user.name)")
                                                    Text("ID: \(userId)")
                                                }
                                            }
                                        }
                                    }
                                    ForEach(question.memberID, id: \.self) { user in
                                        Text(user)
                                    }
                                }
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(question.title)
                                        .font(.headline)
                                    Text("Created on: \(question.createDate, formatter: dateFormatter)")
                                        .font(.subheadline)
                                }
                            }
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
    
    // 日付のフォーマッタ
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    MessageView()
        .environmentObject(ModelData())  // PreviewにModelDataを注入
}
