//
//  ProjectListCell.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import SwiftUI

struct ProjectListCell: View {
    var project: Project
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "person.crop.circle.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(project.projectPath)
                    .foregroundStyle(.primary)
                Text(project.id)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5).cornerRadius(10))
    }
}

#Preview {
    ProjectListCell(project: .init(id: "", projectPath: "Project Name", threadList: [.init(id: "1", errorMessage: ""), .init(id: "2", errorMessage: "?")]))
}
