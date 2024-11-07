//
//  Thread.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import Foundation

struct Thread: Identifiable, Hashable {
    let id: String
    var errorMessage: String
    var createdUserID: String
//    var threadProject: ThreadProject
    var chatMessages: [Message]
    
    init(id: String, errorMessage: String, createdUserID: String, chatMessages: [Message]) {
        self.id = id
        self.errorMessage = errorMessage
        self.createdUserID = createdUserID
        self.chatMessages = chatMessages
    }
    
    init(id: String, errorMessage: String) {
        self.id = id
        self.errorMessage = errorMessage
        self.createdUserID = ""
        self.chatMessages = []
    }
}
