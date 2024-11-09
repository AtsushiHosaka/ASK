//
//  FirebaseStorageAPI.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import Foundation
import FirebaseStorage

class FirebaseStorageAPI {
    static private let storage = Storage.storage().reference()
    
    static func fetchImageData(from imageName: String) async -> Data? {
        let storageRef = storage.child("\(imageName)")
        
        do {
            let imageData = try await storageRef.data(maxSize: 5 * 1024 * 1024)
            
            return imageData
        } catch {
            print("Error fetching image data: \(error)")
            return nil
        }
    }
    
    static func uploadImage(uid: String, imageData: Data) async throws -> String {
        let storageRef = storage.child("\(uid).jpg")
        let _ = try await storageRef.putDataAsync(imageData)
        return "\(uid).jpg"
    }
    static func uploadDirectory(path: String, threadID: String) async throws {
        let fileManager = FileManager.default
        
        // URLから実際のファイルパスを取得
        let directoryPath: String
        if path.hasPrefix("file://") {
            guard let url = URL(string: path) else {
                throw NSError(domain: "FileManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            }
            directoryPath = url.path
        } else {
            directoryPath = path
        }
        
        let directoryURL = URL(fileURLWithPath: directoryPath)
        
        // ディレクトリが存在することを確認
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: directoryPath, isDirectory: &isDirectory) && isDirectory.boolValue else {
            throw NSError(domain: "FileManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Directory not found at path: \(directoryPath)"])
        }
        
        print("Uploading directory at path: \(directoryPath)")
        
        // ベースディレクトリへの参照を作成
        let baseStorageRef = storage.child(threadID)
        
        // 除外するファイル・フォルダのリスト
        let excludedItems = [
            ".git",
            ".env",
            ".DS_Store",
            "node_modules",
            ".gitignore",
            ".idea",
            ".vscode",
            ".swift-version",
            "Pods",
            ".xcodeproj",
            ".xcworkspace",
            "build",
            "DerivedData"
        ]
        
        // ファイルやフォルダが除外対象かどうかをチェックする関数
        func shouldExclude(_ url: URL) -> Bool {
            // 隠しファイル（.で始まるファイル）をチェック
            if url.lastPathComponent.hasPrefix(".") {
                return true
            }
            
            // 除外リストに含まれているかチェック
            return excludedItems.contains(url.lastPathComponent)
        }
        
        // ディレクトリ内のファイルを再帰的に処理する関数
        func uploadContents(of url: URL, to storageRef: StorageReference) async throws {
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            for fileURL in contents {
                // 除外対象のファイル・フォルダはスキップ
                if shouldExclude(fileURL) {
                    print("Skipping excluded item: \(fileURL.path)")
                    continue
                }
                
                let relativePath = fileURL.path.replacingOccurrences(of: directoryPath, with: "")
                let fileStorageRef = storageRef.child(relativePath)
                
                var isDirectory: ObjCBool = false
                fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
                
                if isDirectory.boolValue {
                    try await uploadContents(of: fileURL, to: storageRef)
                } else {
                    print("Uploading file: \(fileURL.path)")
                    let data = try Data(contentsOf: fileURL)
                    _ = try await fileStorageRef.putDataAsync(data)
                }
            }
        }
        
        try await uploadContents(of: directoryURL, to: baseStorageRef)
    }
    
    static func downloadProject(threadID: String) async throws -> FileNode {
        let storageRef = storage.child(threadID)
        
        // ルートディレクトリの情報を取得
        let result = try await storageRef.listAll()
        
        // ルートノードを作成
        var rootNode = FileNode(name: threadID, isDirectory: true, children: [])
        
        // 再帰的にファイル構造を構築
        func processItems(in reference: StorageReference, parent: inout FileNode) async throws {
            let result = try await reference.listAll()
            
            var children: [FileNode] = []
            
            // ファイルの処理
            for item in result.items {
                let data = try await item.data(maxSize: 10 * 1024 * 1024) // 10MB制限
                let content = String(data: data, encoding: .utf8) ?? ""
                let fileNode = FileNode(name: item.name, isDirectory: false, children: nil, content: content)
                children.append(fileNode)
            }
            
            // フォルダの処理
            for prefix in result.prefixes {
                var directoryNode = FileNode(name: prefix.name, isDirectory: true, children: [])
                try await processItems(in: prefix, parent: &directoryNode)
                children.append(directoryNode)
            }
            
            parent.children = children
        }
        
        try await processItems(in: storageRef, parent: &rootNode)
        return rootNode
    }
}

class FileAccessManager {
    static let shared = FileAccessManager()
    private init() {}
    
    func startAccessingSecurityScopedResource(at url: URL) -> Bool {
        return url.startAccessingSecurityScopedResource()
    }
    
    func stopAccessingSecurityScopedResource(at url: URL) {
        url.stopAccessingSecurityScopedResource()
    }
}
