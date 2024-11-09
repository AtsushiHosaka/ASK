//
//  ProjectList.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import SwiftUI

struct ProjectList: View {
    @ObservedObject var dataManager = DataManager.shared
    @Binding var selectedProjectID: String?
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("ASKs")
                    .font(.custom("HelveticaNeue", size: 40))
                    .fontWeight(.heavy)
                    .foregroundStyle(.indigo)
                    .frame(height: 50)
                    .padding(.horizontal)
                
                List(dataManager.projects, id: \.id) { project in
                    ProjectListCell(project: project)
                        .onTapGesture {
                            selectedProjectID = project.id
                        }
                        .background(selectedProjectID == project.id ? Color.blue.opacity(0.1) : Color.clear)
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
                        NewProjectView()
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
