//
//  FirestoreProject.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/08.
//

import Foundation
import FirebaseFirestore

struct FirestoreProject: Codable {
    @DocumentID var id: String?
    var createdAt: Date
    var projectPath: String
    var iconImageName: String
    var memberIDList: [String]
    var editorType: EditorType
    var editorVersion: Float
    var osVersion: Float
    var languageList: [LanguageType]
    
    init(project: Project) {
        self.createdAt = project.createdAt
        self.projectPath = project.projectPath
        self.iconImageName = project.iconImageName
        self.memberIDList = project.memberList.map(\.id!)
        self.editorType = project.editorType
        self.editorVersion = project.editorVersion
        self.osVersion = project.osVersion
        self.languageList = project.languageList
    }
}
