//
//  AttributedString+separate.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI

//extension AttributedString {
//    func components(separatedBy separator: Character) -> [AttributedString] {
//        // Convert AttributedString to its underlying String and attributes
//        let fullString = self.string
//        let components = fullString.components(separatedBy: separator)
//        
//        var attributedComponents: [AttributedString] = []
//        
//        // Track the current position in the original string
//        var currentIndex = fullString.startIndex
//        
//        for component in components {
//            let endIndex = currentIndex.advanced(by: component.count)
//            let range = currentIndex..<endIndex
//            
//            // Extract the attributed substring
//            let attributedComponent = self[range]
//            attributedComponents.append(attributedComponent)
//            
//            // Move past the separator
//            currentIndex = endIndex
//            if currentIndex < fullString.endIndex {
//                currentIndex = fullString.index(after: currentIndex)
//            }
//        }
//        
//        return attributedComponents
//    }
//}

//extension String {
//    func nsRange(fromRange range: Range<Index>) -> NSRange {
//        let from = range.lowerBound
//        let to = range.upperBound
//
//        let location = self.distance(from: startIndex, to: from)
//        let length = self.distance(from: from, to: to)
//
//        return NSRange(location: location, length: length)
//    }
//}
