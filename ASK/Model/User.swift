//
//  User.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import Foundation
import SwiftUI

struct User: Hashable, Identifiable, Codable {
    var id: UUID
    var name: String
    
    private var imageName: String
    var image: Image {
        Image(imageName)
    }
}
