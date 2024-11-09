//
//  ThreadProjectView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/10.
//

import SwiftUI

struct ThreadProjectView: View {
    @Environment(\.dismiss) var dismiss
    
    let threadID: String
    let projectPath: String
    
    @State private var rootNode: FileNode?
    @State private var isLoading = true
    @State private var error: Error?
    @State private var selectedFileContent: String?  // 選択されたファイルの内容
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal)
            
            Group {
                if isLoading {
                    ProgressView("Loading project files...")
                } else if let error = error {
                    Text("Error: \(error.localizedDescription)")
                } else if let rootNode = rootNode {
                    HStack(spacing: 0) {
                        // ファイルツリー（左側）
                        ScrollView([.horizontal, .vertical]) {
                            FileTreeView(node: rootNode, selectedFileContent: $selectedFileContent)
                                .padding()
                        }
                        .frame(width: 200)
                        
                        // 区切り線
                        Divider()
                        
                        // ファイル内容表示（右側）
                        if let content = selectedFileContent {
                            CodeView(filePath: "", code: selectedFileContent ?? "")
                        } else {
                            Text("ファイルを選択してください")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    rootNode = try await FirebaseStorageAPI.downloadProject(threadID: threadID)
                    isLoading = false
                } catch {
                    self.error = error
                    isLoading = false
                }
            }
        }
    }
}

// FileTreeView.swift
struct FileTreeView: View {
    let node: FileNode
    private let depth: Int
    @Binding var selectedFileContent: String?
    
    // メインのイニシャライザ
    init(node: FileNode, selectedFileContent: Binding<String?>) {
        self.node = node
        self.depth = 0
        self._selectedFileContent = selectedFileContent
    }
    
    // 内部で使用する深さを指定するイニシャライザ
    private init(node: FileNode, depth: Int, selectedFileContent: Binding<String?>) {
        self.node = node
        self.depth = depth
        self._selectedFileContent = selectedFileContent
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
                            selectedFileContent = node.content
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
                    FileTreeView(node: child, depth: depth + 1, selectedFileContent: $selectedFileContent)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// オプション: ファイルの内容を表示するビュー
struct FileContentView: View {
    let content: String
    
    var body: some View {
        ScrollView {
            Text(content)
                .padding()
                .font(.system(.body, design: .monospaced))
        }
    }
}

struct FileNode: Identifiable {
    let id = UUID()
    let name: String
    let isDirectory: Bool
    var children: [FileNode]?
    var content: String?  // ファイルの内容
}
