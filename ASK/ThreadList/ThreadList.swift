//
//  ThreadList.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import SwiftUI

struct ThreadList: View {
    @ObservedObject var dataManager = DataManager.shared
    let projectID: String
    
    var project: Project {
        dataManager.projects.first { $0.id == projectID }!
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text("ASK about \(project.projectPath.extractLastPathComponent())")
                            .font(.custom("HelveticaNeue", size: 30))
                            .fontWeight(.heavy)
                        Text(project.createdAt.formatted(.dateTime))
                            .font(.custom("HelveticaNeue", size: 20))
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 60)
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                
                Divider()
                
                List(project.threadList, id: \.id) { thread in
                    NavigationLink {
                        ThreadView(projectID: projectID, threadID: thread.id)
#if os(macOS)
                            .toolbar(.hidden)
#endif
                    } label: {
                        ThreadListCell(projectID: projectID, thread: thread)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .background(Color.clear)
            
            VStack {
                Spacer()
                    
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        NewThreadView(projectID: projectID, projectPath: project.projectPath)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.indigo)
                                .frame(width: 50, height: 50)
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .heavy))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
            .padding()
        }
    }
}
