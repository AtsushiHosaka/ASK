//
//  ThreadList.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import SwiftUI

struct ThreadList: View {
    var project: Project
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("ASK about \(project.projectPath)")
                        .font(.custom("HelveticaNeue", size: 40))
                        .fontWeight(.heavy)
                    Text("2024/01/01~")
                        .font(.custom("HelveticaNeue", size: 20))
                        .foregroundStyle(.secondary)
                }
                .frame(height: 75)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            Divider()
            
            List(project.threadList, id: \.self) { thread in
                NavigationLink {
                    ThreadView(thread: thread)
                } label: {
                    ThreadListCell(thread: thread)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .background(Color.clear)
    }
}

#Preview {
    ThreadList(project: .init(id: "", projectPath: "Stampy", threadList: [.init(id: "", errorMessage: "error in thread"), .init(id: "", errorMessage: "error in thread2")]))
}
