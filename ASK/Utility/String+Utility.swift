//
//  String+Utility.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/10.
//

import Foundation

extension String {
    func extractLastPathComponent() -> String {
        let components = self.split(separator: "/")
        return components.last.map { String($0) } ?? self
    }
}
