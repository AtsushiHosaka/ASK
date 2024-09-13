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
                    ForEach(modelData.threads) { thread in
                        if let threadId = thread.id {  // Threadのidをアンラップ
                            NavigationLink {
                                VStack(alignment: .leading) {
                                    Text("Question: \(thread.title)")
                                        .font(.headline)
                                    Text("Created on: \(thread.createDate, formatter: dateFormatter)")
                                        .font(.subheadline)
                                    
                                    // ユーザー情報を表示
//                                    if let member = thread.memberID {
                                    ForEach(thread.memberID, id: \.self) { user in
//                                            if let userId = user.id {  // Userのidをアンラップ
//                                                HStack {
//                                                    Text("User: \(user.name)")
//                                                    Text("ID: \(userId)")
//                                                }
//                                            }
                                            Text(user)
                                        }
//                                    }
                                }
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(thread.title)
                                        .font(.headline)
                                    Text("Created on: \(thread.createDate, formatter: dateFormatter)")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    Task {
                        // 初回表示時にスレッドのリスナーがセットされていることを確認
                        if modelData.threads.isEmpty {
                            await modelData.loadThreads()
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
