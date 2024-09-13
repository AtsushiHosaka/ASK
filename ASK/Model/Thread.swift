//
//  Thread.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import Foundation
import FirebaseFirestore

struct Thread: Hashable, Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var createDate: Date
    
    var memberID: [String]
    var member: [User]?
}
