//
//  ThreadView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import SwiftUI

struct ThreadView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = DataManager.shared
    
    let projectID: String
    let threadID: String
    
    var project: Project? {
        dataManager.projects.first { $0.id == projectID }
    }
    
    var thread: Thread? {
        project?.threadList.first { $0.id == threadID }
    }
    
    var body: some View {
        Group {
            if let thread = thread {
                VStack {
                    HStack(alignment: .center, spacing: 20) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        VStack(alignment: .leading) {
                            Text(thread.errorMessage)
                                .font(.custom("HelveticaNeue", size: 25))
                                .fontWeight(.heavy)
                            
                            Text("5分前")
                                .font(.custom("HelveticaNeue", size: 15))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        NavigationLink {
                            ThreadProjectView(threadID: threadID, projectPath: project?.projectPath ?? "")
                        } label: {
                            Image(systemName: "text.and.command.macwindow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            
                        }) {
                            Image(systemName: "ellipsis")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(height: 60)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    ChatView(projectID: projectID, threadID: threadID)
                }
            } else {
                // プロジェクトまたはスレッドが見つからない場合の表示
                Text("Loading...")
                    .onAppear {
                        print("Project or Thread not found")
                        print("ProjectID: \(projectID)")
                        print("ThreadID: \(threadID)")
                    }
            }
        }
    }
}
