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
}
