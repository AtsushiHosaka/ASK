//
//  Item.swift
//  ASK_iOS
//
//  Created by 保坂篤志 on 2024/09/14.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
