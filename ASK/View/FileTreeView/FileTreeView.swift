//
//  FileTreeView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/10.
//


import SwiftUI

struct FileTreeView: View {
    let node: FileNode
    private let depth: Int
    private let parentPath: String  // 親ディレクトリのパスを追跡
    @Binding var selectedFileContent: String
    @Binding var selectedFilePath: String
    
    // メインのイニシャライザ
    init(node: FileNode, parentPath: String = "", selectedFileContent: Binding<String>, selectedFilePath: Binding<String>) {
        self.node = node
        self.depth = 0
        self.parentPath = parentPath
        self._selectedFileContent = selectedFileContent
        self._selectedFilePath = selectedFilePath
    }
    
    // 内部で使用する深さを指定するイニシャライザ
    private init(node: FileNode, depth: Int, parentPath: String, selectedFileContent: Binding<String>, selectedFilePath: Binding<String>) {
        self.node = node
        self.depth = depth
        self.parentPath = parentPath
        self._selectedFileContent = selectedFileContent
        self._selectedFilePath = selectedFilePath
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // 現在のノードを表示
            if depth > 0 {  // ルートノードは表示しない場合
                HStack {
                    if node.isDirectory {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.blue)
                        Text(node.name)
                            .fontWeight(.medium)
                    } else {
                        Button(action: {
                            selectedFileContent = node.content ?? ""
                            selectedFilePath = (parentPath.isEmpty ? node.name : "\(parentPath)/\(node.name)")
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.gray)
                                Text(node.name)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.leading, CGFloat(depth * 20))  // 階層に応じてインデント
            }
            
            // 子ノードを表示（ディレクトリの場合）
            if node.isDirectory, let children = node.children {
                ForEach(children) { child in
                    FileTreeView(
                        node: child,
                        depth: depth + 1,
                        parentPath: depth == 0 ? "" : (parentPath.isEmpty ? node.name : "\(parentPath)/\(node.name)"),
                        selectedFileContent: $selectedFileContent,
                        selectedFilePath: $selectedFilePath
                    )
                }
            }
        }
        .padding(.vertical, 2)
    }
}
