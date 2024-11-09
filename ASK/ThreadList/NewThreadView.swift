////
////  NewThreadView.swift
////  ASK
////
////  Created by 保坂篤志 on 2024/11/09.
////
//
//import SwiftUI
//import Firebase
//import FirebaseStorage
//
//struct NewProjectView: View {
//    @Environment(\.dismiss) var dismiss
//    @ObservedObject var dataManager = DataManager.shared
//    
//    @State private var selectedFileName: String = "プロジェクトを選択"
//    @State private var selectedDirectry: String = ""
//    @State private var selectedCode: String = ""
//    @State private var errorContent: String = ""
//    @State private var errorMessage: String = ""
//    @State private var selectediOSVersion = ""
//    @State private var selectedEditor = ""
//    @State private var selectedEditorVersion = ""
//    
//    @State private var emptyMessage: String = ""
//
//    // iOSバージョンの選択肢（最新: iOS 18.0）
//    let iOSVersions = [
//        "iOS 18.0", "iOS 17.1", "iOS 17.0",
//        "iOS 16.4", "iOS 16.3", "iOS 16.2", "iOS 16.1", "iOS 16.0",
//        "iOS 15.5", "iOS 15.4", "iOS 15.3", "iOS 15.2", "iOS 15.1", "iOS 15.0"
//    ]
//
//    // エディターの選択肢
//    let editors = ["Xcode", "VSCode", "AppCode"]
//
//    // エディターバージョンの選択肢
//    let editorVersions = [
//        "Xcode 15.1", "Xcode 15.0",
//        "Xcode 14.3", "Xcode 14.2", "Xcode 14.1", "Xcode 14.0",
//        "VSCode 1.82", "VSCode 1.81", "VSCode 1.80",
//        "AppCode 2023.2", "AppCode 2023.1"
//    ]
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            HStack(alignment: .center) {
//                Button(action: {
//                    dismiss()
//                }) {
//                    Image(systemName: "chevron.left")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
//                }
//                .buttonStyle(PlainButtonStyle())
//                
//                Spacer()
//            }
//            .padding(.horizontal)
//            
//            Spacer()
//            
//            Text("質問するプロジェクトを作成")
//                .font(.custom("HelveticaNeue", size: 30))
//                .fontWeight(.heavy)
//                .foregroundStyle(.indigo)
//            
//            if !selectedFileName.isEmpty && !selectedCode.isEmpty {
//                CodeView(fileName: selectedFileName, code: selectedCode)
//            }
//            
//            Button(action: {
//                selectProjectFile()
//            }) {
//                NewQuestionButton(icon: "filemenu.and.cursorarrow", text: selectedFileName)
//                    .frame(maxWidth: 300)
//            }
//            .buttonStyle(ClearBackgroundButtonStyle())
//            
//            NewQuestionTextField(title: "エラー内容", text: $errorContent)
//            
//            NewQuestionTextField(title: "エラー文章", text: $errorMessage)
//            
//            // エディターのセレクター
//            Picker("エディター", selection: $selectedEditor) {
//                ForEach(editors, id: \.self) { editor in
//                    Text(editor).tag(editor)
//                }
//            }
//            .pickerStyle(MenuPickerStyle())
//            .frame(maxWidth: 300)
//            
//            // エディターバージョンのセレクター
//            Picker("エディターバージョン", selection: $selectedEditorVersion) {
//                ForEach(editorVersions, id: \.self) { version in
//                    Text(version).tag(version)
//                }
//            }
//            .pickerStyle(MenuPickerStyle())
//            .frame(maxWidth: 300)
//            
//            
//            if !emptyMessage.isEmpty {
//                Text(emptyMessage)
//                    .foregroundStyle(.red)
//            }
//            
//            Button(action: {
//                if errorContent.isEmpty {
//                    emptyMessage = "エラー内容を入力してください"
//                }else {
//                    addQuestion()
//                }
//            }) {
//                NewQuestionButton(icon: "paperplane.fill", text: "質問を作成")
//                    .frame(maxWidth: 300)
//            }
//            .buttonStyle(ClearBackgroundButtonStyle())
//            
//            Spacer()
//        }
//        .padding()
//    }
//    
//    private func selectProjectFile() {
//        let panel = NSOpenPanel()
//        panel.title = "プロジェクトファイルを選択"
//        
//        panel.canChooseFiles = true
//        panel.canChooseDirectories = true
//        
//        panel.begin { result in
//            if result == .OK, let url = panel.url {
//                selectedFileName = url.lastPathComponent
//                selectedDirectry = url.absoluteString
//            }
//        }
//    }
//    
//    private func addQuestion() {
//        guard let userId = LoginManager.loadUserUID() else { return }
//        
//        var message = Message(date: Date(), content: errorContent, sentBy: userId)
//        
//        if !selectedFileName.isEmpty && !selectedCode.isEmpty {
//            message.code = selectedCode
//            message.fileName = selectedFileName
//        }
//        
//        var messages = [message]
//        
//        if !errorMessage.isEmpty {
//            let message = Message(date: Date(), content: errorMessage, sentBy: userId)
//            messages.append(message)
//        }
//        
//        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
//        messages.append(Message(date: Date(), content: "macOSのバージョンは\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)です", sentBy: userId))
//        
//        if !selectediOSVersion.isEmpty {
//            let message = Message(date: Date(), content: "iOSのバージョンは\(selectediOSVersion)です", sentBy: userId)
//            messages.append(message)
//        }
//        
//        if !selectedEditor.isEmpty {
//            let message = Message(date: Date(), content: "エディタは\(selectedEditor)です", sentBy: userId)
//            messages.append(message)
//        }
//        
//        if !selectedEditorVersion.isEmpty {
//            let message = Message(date: Date(), content: "エディタのバージョンは\(selectedEditorVersion)です", sentBy: userId)
//            messages.append(message)
//        }
//        
////        Task {
////            let newQuestion = Question(
////                title: "質問",
////                createDate: Date(),
////                memberID: [userId],
////                messages: messages
////            )
////
////            await dataManager.addQuestion(newQuestion)
////
////            await dataManager.loadQuestions()
////        }
//    }
//}
