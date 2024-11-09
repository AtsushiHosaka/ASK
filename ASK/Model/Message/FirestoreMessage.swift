//
//  FirestoreMessage.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct FirestoreMessage: Codable {
    @DocumentID var id: String?
    var date: Date
    var content: String
    var sentBy: String
    
    var fileName: String?
    var code: String?
    var codeDiffBefore: String?
    var codeDiffAfter: String?
    
    var replyTo: String?
    
    init(id: String? = nil, date: Date, content: String, sentBy: String, fileName: String? = nil, code: String? = nil, codeDiffBefore: String? = nil, codeDiffAfter: String? = nil, replyTo: String? = nil) {
        self.id = id
        self.date = date
        self.content = content
        self.sentBy = sentBy
        self.fileName = fileName
        self.code = code
        self.codeDiffBefore = codeDiffBefore
        self.codeDiffAfter = codeDiffAfter
        self.replyTo = replyTo
    }
    
    init(message: Message) {
        self.id = nil
        self.date = message.date
        self.content = message.content
        self.sentBy = message.sentBy
        self.fileName = message.fileName
        self.code = message.code
        self.codeDiffBefore = message.codeDiffBefore
        self.codeDiffAfter = message.codeDiffAfter
        self.replyTo = message.replyTo
    }
}
