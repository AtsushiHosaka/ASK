//
//  FirestoreThread.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/08.
//

import Foundation
import FirebaseFirestore

struct FirestoreThread: Codable {
    @DocumentID var id: String?
    var errorMessage: String
    var createdUserID: String
    
    init(errorMessage: String, createdUserID: String) {
        self.errorMessage = errorMessage
        self.createdUserID = createdUserID
    }
    
    init(thread: Thread) {
        self.id = thread.id
        self.errorMessage = thread.errorMessage
        self.createdUserID = thread.createdUserID
    }
}
