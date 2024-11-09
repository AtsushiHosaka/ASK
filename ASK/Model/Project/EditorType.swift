//
//  EditorType.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import Foundation

enum EditorType: String, Codable, CaseIterable {
    case Xcode
    case VSCode
    
    init?(from string: String) {
        self.init(rawValue: string)
    }
}
