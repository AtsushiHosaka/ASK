//
//  Thread.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import Foundation

struct Thread: Hashable, Codable, Identifiable {
    var id: UUID
    var title: String
    var createDate: Date
    var member: [UUID]
}
