//
//  ProjectList.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import SwiftUI

struct ProjectList: View {
    @ObservedObject var dataManager = DataManager.shared
    
    @Binding var selectedProject: Project?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("ASKs")
                .font(.custom("HelveticaNeue", size: 40))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
                .frame(height: 75)
                .padding()
            
            List(dataManager.projects, id: \.self, selection: $selectedProject) { project in
                ProjectListCell(project: project)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
                
        }
        .background(Color.clear)
    }
}

#Preview {
    ProjectList(selectedProject: .constant(.init(id: "1", projectPath: "SwiftUI", threadList: [.init(id: "1", errorMessage: ""), .init(id: "2", errorMessage: "?")])))
}
