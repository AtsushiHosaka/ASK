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
    @State private var selectedFileContent: String = ""
    @State private var selectedFilePath: String = ""
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""
    
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
                
                Button(action: {
                    if !isLoading && error == nil {
                        saveProjectToDirectory()
                    }
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            
            if isLoading {
                Spacer()
                ProgressView("Loading project files...")
                Spacer()
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
            } else if let rootNode = rootNode {
                HStack(spacing: 0) {
                    // ファイルツリー（左側）
                    ScrollView([.horizontal, .vertical]) {
                        FileTreeView(node: rootNode, selectedFileContent: $selectedFileContent, selectedFilePath: $selectedFilePath)
                            .padding()
                    }
                    .frame(width: 200)
                    
                    // 区切り線
                    Divider()
                    
                    // ファイル内容表示（右側）
                    if !selectedFileContent.isEmpty {
                        CodeView(filePath: "", code: selectedFileContent)
                    } else {
                        Text("ファイルを選択してください")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    var downloadedNode = try await FirebaseStorageAPI.downloadProject(threadID: threadID)
                    
                    downloadedNode.name = projectPath.extractLastPathComponent()
                    rootNode = downloadedNode
                    isLoading = false
                } catch {
                    self.error = error
                    isLoading = false
                }
            }
        }
    }
    
    private func saveProjectToDirectory() {
        guard let rootNode = rootNode else { return }
        
        let panel = NSSavePanel()
        panel.title = "プロジェクトの保存先を選択"
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = rootNode.name
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    try rootNode.saveToDirectory(at: url.deletingLastPathComponent())
                } catch {
                    showingSaveError = true
                    saveErrorMessage = error.localizedDescription
                }
            }
        }
    }
}


