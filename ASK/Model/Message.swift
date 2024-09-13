//
//  Message.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import Foundation
import SwiftUI

struct Message: Hashable, Identifiable, Codable {
    var id: UUID
    var date: Date
    var content: String
    
    private var imageName: String
    var image: Image {
        Image(imageName)
    }
    
    var code: String
    var replyTo: UUID
}
