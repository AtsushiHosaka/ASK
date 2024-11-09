//
//  Message.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/08.
//

import Foundation
import SwiftUI

struct Message: Hashable, Identifiable {
    var id: String
    var date: Date
    var content: String
    var sentBy: String
    var sentUser: User
    
    var fileName: String?
    var code: String?
    var codeDiffBefore: String?
    var codeDiffAfter: String?
    
    var replyTo: String?
    
    init(date: Date, content: String, sentBy: String, fileName: String? = nil, code: String? = nil, codeDiffBefore: String? = nil, codeDiffAfter: String? = nil, replyTo: String? = nil) {
        self.id = UUID().uuidString
        self.date = date
        self.content = content
        self.sentBy = sentBy
        self.sentUser = defaultUser
        self.fileName = fileName
        self.code = code
        self.codeDiffBefore = codeDiffBefore
        self.codeDiffAfter = codeDiffAfter
        self.replyTo = replyTo
    }
    
    init(id: String, date: Date, content: String, sentBy: String, sentUser: User, fileName: String? = nil, code: String? = nil, codeDiffBefore: String? = nil, codeDiffAfter: String? = nil, replyTo: String? = nil) {
        self.id = id
        self.date = date
        self.content = content
        self.sentBy = sentBy
        self.sentUser = sentUser
        self.fileName = fileName
        self.code = code
        self.codeDiffBefore = codeDiffBefore
        self.codeDiffAfter = codeDiffAfter
        self.replyTo = replyTo
    }
    
    init(firestoreMessage: FirestoreMessage) {
        self.id = firestoreMessage.id!
        self.date = firestoreMessage.date
        self.content = firestoreMessage.content
        self.sentBy = firestoreMessage.sentBy
        self.sentUser = User(id: "bTjcp7QPo5Sf6ytaRhW3mPPbJw52", name: "error", imageName: "as.jpeg")
        self.fileName = firestoreMessage.fileName
        self.code = firestoreMessage.code
        self.codeDiffBefore = firestoreMessage.codeDiffBefore
        self.codeDiffAfter = firestoreMessage.codeDiffAfter
        self.replyTo = firestoreMessage.replyTo
    }
    
    let defaultUser = User(id: "bTjcp7QPo5Sf6ytaRhW3mPPbJw52", name: "error", imageName: "as.jpeg")
}
