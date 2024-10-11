//
//  NewQuestionView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/10/12.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct NewQuestionView: View {
    @ObservedObject var dataManager = DataManager.shared
    
    @State private var selectedFileName: String = ""
    @State private var selectedCode: String = ""
    @State private var errorContent: String = ""
    @State private var errorMessage: String = ""
    @State private var emptyMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("新しい質問を作成")
                .font(.custom("HelveticaNeue", size: 30))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
            
            if !selectedFileName.isEmpty && !selectedCode.isEmpty {
                CodeView(fileName: selectedFileName, code: selectedCode)
            }
            
            Button(action: {
                selectProjectFile()
            }) {
                NewQuestionButton(icon: "filemenu.and.cursorarrow", text: "プロジェクトファイルを選択")
                    .frame(maxWidth: 300)
            }
            .buttonStyle(ClearBackgroundButtonStyle())
            
            NewQuestionTextField(title: "エラー内容", text: $errorContent)
            
            NewQuestionTextField(title: "エラー文章", text: $errorMessage)
            
            if !emptyMessage.isEmpty {
                Text(emptyMessage)
                    .foregroundStyle(.red)
            }

            Button(action: {
                if errorContent.isEmpty {
                    emptyMessage = "エラー内容を入力してください"
                }else {
                    addQuestion()
                }
            }) {
                NewQuestionButton(icon: "paperplane.fill", text: "質問を作成")
                    .frame(maxWidth: 300)
            }
            .buttonStyle(ClearBackgroundButtonStyle())
            
            Spacer()
        }
        .padding()
    }
    
    private func selectProjectFile() {
        let panel = NSOpenPanel()
        panel.title = "プロジェクトファイルを選択"
        
        panel.canChooseFiles = true
        panel.canChooseDirectories = false // ディレクトリ選択を無効にする（ファイルのみ選択）
        
        panel.begin { result in
            if result == .OK, let url = panel.url {
                selectedFileName = url.lastPathComponent // 選択したファイルの名前を設定
                readFileContent(from: url) // ファイルの内容を読み取る
            }
        }
    }
    
    private func readFileContent(from url: URL) {
        do {
            // ファイルの内容を読み込み、selectedCodeに代入
            selectedCode = try String(contentsOf: url, encoding: .utf8)
            print("選択したファイルの内容: \(selectedCode)")
        } catch {
            print("ファイルを読み込む際にエラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    private func addQuestion() {
        guard let userId = LoginManager.loadUserUID() else { return }
        
        var message = Message(date: Date(), content: errorContent, sentBy: userId)
        
        if !selectedFileName.isEmpty && !selectedCode.isEmpty {
            message.code = selectedCode
            message.fileName = selectedFileName
        }
        
        var messages = [message]
        
        if !errorMessage.isEmpty {
            let message = Message(date: Date(), content: errorMessage, sentBy: userId)
            messages.append(message)
        }
        
        Task {
            let newQuestion = Question(
                title: "質問",
                createDate: Date(),
                memberID: [userId],
                messages: messages
            )
            
            await dataManager.addQuestion(newQuestion)
            
            await dataManager.loadQuestions()
        }
    }
}
