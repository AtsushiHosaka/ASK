//
//  Message.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Message: Hashable, Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var content: String
    var sentBy: String
    
    var fileName: String?
    var code: String?
    
    var replyTo: String?
    
    init(id: String? = nil, date: Date, content: String, sentBy: String, fileName: String? = nil, code: String? = nil, replyTo: String? = nil) {
        self.id = id
        self.date = date
        self.content = content
        self.sentBy = sentBy
        self.fileName = fileName
        self.code = code
        self.replyTo = replyTo
    }
}
