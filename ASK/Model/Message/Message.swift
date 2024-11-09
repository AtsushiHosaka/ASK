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
    var sentUser: User?
    
    var filePath: String?
    var code: String?
    var codeDiffBefore: String?
    var codeDiffAfter: String?
    
    var replyTo: String?
    
    init(date: Date, content: String, sentBy: String, sentUser: User? = nil, filePath: String? = nil, code: String? = nil, codeDiffBefore: String? = nil, codeDiffAfter: String? = nil, replyTo: String? = nil) {
        self.id = UUID().uuidString
        self.date = date
        self.content = content
        self.sentBy = sentBy
        self.sentUser = sentUser
        self.filePath = filePath
        self.code = code
        self.codeDiffBefore = codeDiffBefore
        self.codeDiffAfter = codeDiffAfter
        self.replyTo = replyTo
    }
    
    init(id: String, date: Date, content: String, sentBy: String, sentUser: User, filePath: String? = nil, code: String? = nil, codeDiffBefore: String? = nil, codeDiffAfter: String? = nil, replyTo: String? = nil) {
        self.id = id
        self.date = date
        self.content = content
        self.sentBy = sentBy
        self.sentUser = sentUser
        self.filePath = filePath
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
        self.sentUser = nil
        self.filePath = firestoreMessage.filePath
        self.code = firestoreMessage.code
        self.codeDiffBefore = firestoreMessage.codeDiffBefore
        self.codeDiffAfter = firestoreMessage.codeDiffAfter
        self.replyTo = firestoreMessage.replyTo
    }
}
