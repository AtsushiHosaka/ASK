//
//  MessageView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import AppKit

struct MessageView: View {
    @EnvironmentObject var modelData: ModelData
    
    var question: Question
    @State private var newMessageContent: String = ""
    @State private var textHeight: CGFloat = 30
    @State private var code: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            List(question.messages) { message in
                Text(message.content)
            }
            
            Spacer()
            
            
            
            VStack {
                Text(code)
                
                HStack {
                    TextEditor(text: $newMessageContent)
                        .font(.system(size: 17))
                        .frame(height: max(30, textHeight))
                        .padding()
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear {
                                calculateHeight(geometry: geometry)
                            }
                            .onChange(of: newMessageContent) {
                                calculateHeight(geometry: geometry)
                            }
                        })
                        .border(Color.gray, width: 1)
                    
                    // ファイル選択ボタンを追加
                    Button(action: {
                        selectSwiftFile()
                    }) {
                        Text("Select File")
                    }
                    .padding(.trailing)
                    
                    Button(action: {
                        let newMessage = Message(date: Date(), content: newMessageContent, sentBy: UserPersistence.loadUserUID()!)
                        FirebaseAPI.addMessageToFirestore(question: question, message: newMessage)
                        newMessageContent = ""
                    }) {
                        Text("Send")
                    }
                    .padding(.trailing)
                }
                .padding()
            }
        }
        .onAppear {
            if let id = question.id {
                modelData.addMessagesListener(for: id)
            }
        }
    }
    
    private func calculateHeight(geometry: GeometryProxy) {
        let width = geometry.size.width
        let size = CGSize(width: width, height: .infinity)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 17)
        ]
        let attributedText = NSAttributedString(string: newMessageContent, attributes: attributes)
        let boundingRect = attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        textHeight = min(boundingRect.height * 0.95 + 20, 200)
    }
    
    private func selectSwiftFile() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["swift"] // .swiftファイルのみを許可
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                do {
                    let fileContents = try String(contentsOf: url, encoding: .utf8)
                    code = fileContents // ファイル内容をcodeに代入
                } catch {
                    print("ファイルの読み込みに失敗しました: \(error)")
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    MessageView(question: Question(title: "テスト", createDate: Date(), memberID: ["as", "atsushi"], messages: []))
        .environmentObject(ModelData())
}
