//
//  NewThreadView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/09.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct NewThreadView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = DataManager.shared
    @ObservedObject var loginManager = LoginManager.shared
    
    var projectID: String
    var projectPath: String

    @State private var errorMessage: String = ""
    @State private var selectedCode: String = ""
    @State private var selectedFilePath: String = "エラーが起きているファイルを選択"
    
    @State private var emptyMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
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
            
            Spacer()
            
            Text("\(projectPath.extractLastPathComponent())にスレッドを追加")
                .font(.custom("HelveticaNeue", size: 30))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
            
            NewQuestionTextField(title: "エラーメッセージ", text: $errorMessage)
            
            Button(action: {
                selectErrorFilePath()
            }) {
                NewQuestionButton(icon: "filemenu.and.cursorarrow", text: selectedFilePath)
                    .frame(maxWidth: 300)
            }
            .buttonStyle(ClearBackgroundButtonStyle())
            
            if !emptyMessage.isEmpty {
                Text(emptyMessage)
                    .foregroundStyle(.red)
            }
            
            Button(action: {
                if errorMessage.isEmpty {
                    emptyMessage = "エラー内容を入力してください"
                }else {
                    addThread()
                }
            }) {
                NewQuestionButton(icon: "paperplane.fill", text: "スレッドを作成")
                    .frame(maxWidth: 300)
            }
            .buttonStyle(ClearBackgroundButtonStyle())
            
            Spacer()
        }
        .padding()
    }
    
    private func selectErrorFilePath() {
        let panel = NSOpenPanel()
        panel.title = "エラーを起こしているファイルを選択"
        
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        
        let projectURL = URL(fileURLWithPath: projectPath, isDirectory: true)
        panel.directoryURL = projectURL
        
        panel.begin { result in
            if result == .OK, let url = panel.url {
                selectedFilePath = url.absoluteString
                
                do {
                    selectedCode = try String(contentsOf: url, encoding: .utf8)
                } catch {
                    print("ファイルの読み込みに失敗しました: \(error.localizedDescription)")
                    selectedCode = ""
                }
            }
        }
    }
    
    private func addThread() {
        guard let userId = LoginManager.loadUserUID() else { return }
        
        var message = Message(date: Date(), content: "エラー内容：\(errorMessage)", sentBy: userId)
        message.filePath = selectedFilePath
        message.code = selectedCode
        
        let messages = [message]
        
        let thread = Thread(id: UUID().uuidString, errorMessage: errorMessage, createdUserID: userId, chatMessages: messages)
        
        Task {
            do {
                let threadID = try await FirestoreAPI.addThreadWithReturnThreadID(toProjectID: projectID, thread: thread)
                
                try await FirebaseStorageAPI.uploadDirectory(path: projectPath, threadID: threadID)
                
                if !dataManager.isListeningThreadList(ofProjectID: projectID) {
                    await dataManager.addThreadsListener(for: projectID)
                }
                
                dismiss()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
