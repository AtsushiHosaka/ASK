//
//  User.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct User: Hashable, Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    
    var imageName: String
    var imageData: Data?
    
    init(id: String? = nil, name: String, imageName: String, imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.imageData = imageData
    }
}
