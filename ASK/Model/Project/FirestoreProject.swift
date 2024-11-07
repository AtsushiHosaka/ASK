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
    var languageList: [LanguageType]
}
