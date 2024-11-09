//
//  NewQuestionView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/10/12.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct NewProjectView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = DataManager.shared
    @ObservedObject var loginManager = LoginManager.shared
    
    @State private var selectedImage: NSImage?
    @State private var imageData: Data?
    @State private var selectedFilePath: String = "プロジェクトを選択"
    @State private var selectedDirectry: String = ""
    @State private var selectediOSVersion = ""
    @State private var selectedEditor: EditorType = .Xcode
    @State private var selectedEditorVersion: String = ""
    @State private var selectedLanguageTypes: [LanguageType] = []
    
    @State private var emptyMessage: String = ""

    // iOSバージョンの選択肢（最新: iOS 18.0）
    let iOSVersions = [
        "iOS 18.0", "iOS 17.1", "iOS 17.0",
        "iOS 16.4", "iOS 16.3", "iOS 16.2", "iOS 16.1", "iOS 16.0",
        "iOS 15.5", "iOS 15.4", "iOS 15.3", "iOS 15.2", "iOS 15.1", "iOS 15.0"
    ]
    
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
            
            Text("質問するプロジェクトを作成")
                .font(.custom("HelveticaNeue", size: 30))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
            
            Button {
                selectImage()
            } label: {
                if let selectedImage = selectedImage {
                    Image(nsImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                }
            }
            .buttonStyle(ClearBackgroundButtonStyle())
            
            Text("アイコンを選択")
                .font(.custom("HelveticaNeue", size: 16))
                .foregroundStyle(.secondary)
                .padding(.top, -20)
            
            Button(action: {
                selectProjectFile()
            }) {
                NewQuestionButton(icon: "filemenu.and.cursorarrow", text: selectedFilePath)
                    .frame(maxWidth: 300)
            }
            .buttonStyle(ClearBackgroundButtonStyle())
            
            // エディターの選択肢をEditorTypeに変更
            Picker("エディター", selection: $selectedEditor) {
                ForEach(EditorType.allCases, id: \.self) { editor in
                    Text(editor.rawValue).tag(editor)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: 300)
            
            // エディターバージョンの入力欄を追加
            NewQuestionTextField(title: "エディターバージョン", text: $selectedEditorVersion)
                .frame(maxWidth: 300)
            
            if !emptyMessage.isEmpty {
                Text(emptyMessage)
                    .foregroundStyle(.red)
            }
            
            Button {
                if !(selectedImage == nil || selectedDirectry.isEmpty) {
                    addQuestion()
                }
            } label: {
                NewQuestionButton(icon: "paperplane.fill", text: "プロジェクトを作成")
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
        panel.canChooseDirectories = true
        
        panel.begin { result in
            if result == .OK, let url = panel.url {
                // セキュリティスコープドアクセスのためにURLを保存
                selectedFilePath = url.lastPathComponent
                selectedDirectry = url.path  // absoluteStringではなくpathを使用
                
                // オプション: セキュリティスコープドブックマークを作成して保存
                if let bookmarkData = try? url.bookmarkData(options: .withSecurityScope,
                                                           includingResourceValuesForKeys: nil,
                                                           relativeTo: nil) {
                    UserDefaults.standard.set(bookmarkData, forKey: "ProjectDirectoryBookmark")
                }
            }
        }
    }
    
    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.begin { response in
            if response == .OK, let url = panel.url, let nsImage = NSImage(contentsOf: url) {
                self.selectedImage = nsImage
                self.imageData = nsImage.tiffRepresentation
            }
        }
    }
    
    private func addQuestion() {
        guard let userId = LoginManager.loadUserUID() else { return }
        guard let imageData else { return }
        
        var memberList = [User]()
        if let currentUser = loginManager.currentUser {
            memberList.append(currentUser)
        }
        
        let osInfo = ProcessInfo.processInfo.operatingSystemVersion
        let osVersion: Float = Float(osInfo.majorVersion) + Float(osInfo.minorVersion) / 100
        
        let editorVersionFloat = Float(selectedEditorVersion) ?? 0
        
        Task {
            do {
                let imageName = try await FirebaseStorageAPI.uploadImage(uid: userId, imageData: imageData)
                let newProject = Project(id: UUID().uuidString, projectPath: selectedDirectry, iconImageName: imageName, createdAt: Date(), memberList: memberList, threadList: [Thread](), editorType: selectedEditor, editorVersion: editorVersionFloat, osVersion: osVersion, languageList: selectedLanguageTypes)
                
                try await FirestoreAPI.addProject(project: newProject)
                
                dismiss()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
