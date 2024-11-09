//
//  Project.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import Foundation

struct Project: Identifiable, Hashable {
    let id: String
    var projectPath: String
    var iconImageName: String
    var iconImage: Data?
    var createdAt: Date
    var memberList: [User]
    var threadList: [Thread]
    var editorType: EditorType
    var editorVersion: Float
    var osVersion: Float
    var languageList: [LanguageType]
    
    init(id: String, projectPath: String, iconImageName: String, iconImage: Data? = nil, createdAt: Date, memberList: [User], threadList: [Thread], editorType: EditorType, editorVersion: Float, osVersion: Float, languageList: [LanguageType]) {
        self.id = id
        self.projectPath = projectPath
        self.iconImageName = iconImageName
        self.iconImage = iconImage
        self.createdAt = createdAt
        self.memberList = memberList
        self.threadList = threadList
        self.editorType = editorType
        self.editorVersion = editorVersion
        self.osVersion = osVersion
        self.languageList = languageList
    }
    
    init(id: String, projectPath: String, threadList: [Thread]) {
        self.id = id
        self.projectPath = projectPath
        self.iconImageName = ""
        self.iconImage = nil
        self.createdAt = .distantPast
        self.memberList = []
        self.threadList = threadList
        self.editorType = .Xcode
        self.editorVersion = 0
        self.osVersion = 0
        self.languageList = []
    }
    
    init(firestoreProject: FirestoreProject) {
        self.id = firestoreProject.id!
        self.projectPath = firestoreProject.projectPath
        self.iconImageName = firestoreProject.iconImageName
        self.iconImage = nil
        self.createdAt = firestoreProject.createdAt
        self.memberList = []
        self.threadList = []
        self.editorType = firestoreProject.editorType
        self.editorVersion = firestoreProject.editorVersion
        self.editorVersion = firestoreProject.editorVersion
        self.osVersion = firestoreProject.osVersion
        self.languageList = firestoreProject.languageList
    }
    
    mutating func updateData(with newData: Project) {
        self.projectPath = newData.projectPath
        self.iconImageName = newData.iconImageName
        self.iconImage = newData.iconImage
        self.createdAt = newData.createdAt
        self.memberList = newData.memberList
        self.threadList = newData.threadList
        self.editorType = newData.editorType
        self.editorVersion = newData.editorVersion
        self.osVersion = newData.osVersion
        self.languageList = newData.languageList
    }
}
