//
//  FileNode.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/10.
//


import SwiftUI

struct FileNode: Identifiable {
    let id = UUID()
    var name: String
    let isDirectory: Bool
    var children: [FileNode]?
    var content: String?  // ファイルの内容
    
    
    func saveToDirectory(at baseURL: URL) throws {
        let fileManager = FileManager.default
        let nodeURL = baseURL.appendingPathComponent(name)
        
        if isDirectory {
            // ディレクトリの作成
            try fileManager.createDirectory(at: nodeURL, withIntermediateDirectories: true)
            
            // 子要素の保存
            if let children = children {
                for child in children {
                    try child.saveToDirectory(at: nodeURL)
                }
            }
        } else {
            // ファイルの作成
            if let content = content {
                try content.write(to: nodeURL, atomically: true, encoding: .utf8)
            }
        }
    }
}