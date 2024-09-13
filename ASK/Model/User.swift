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
    
    private var imageName: String
    var image: Image {
        Image(imageName)
    }
}
