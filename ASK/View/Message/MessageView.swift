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
    @State private var fileName: String = ""
    @State private var code: String = ""
    @State private var scrollToMessageID: String? = nil
    
    var messages: [Message] {
        question.messages ?? []
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollViewReader { proxy in
                List(messages) { message in
                    if let replyTo = message.replyTo,
                       let repliedMessage = getRepliedMessage(id: replyTo) {
                        ReplyRow(message: message)
                            .onTapGesture {
                                scrollToMessageID = repliedMessage.id
                                proxy.scrollTo(repliedMessage.id, anchor: .top)
                                
                            }
                    }
                    MessageRow(message: message)
                        .id(message.id)
                }
                .onAppear {
                    if let lastMessage = messages.last {
                        scrollToMessageID = lastMessage.id
                        
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            Spacer()
            
            VStack {
                if !code.isEmpty {
                    CodeView(fileName: fileName, code: code)
                }
                
                HStack {
                    TextEditor(text: $newMessageContent)
                        .font(.system(size: 14))
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
                        var newMessage = Message(date: Date(), content: newMessageContent, sentBy: UserPersistence.loadUserUID()!)
                        if !code.isEmpty {
                            newMessage.fileName = fileName
                            newMessage.code = code
                        }
                        Task {
                            try await FirebaseAPI.addMessageToFirestore(question: question, message: newMessage)
                        }
                        newMessageContent = ""
                        fileName = ""
                        code = ""
                    }) {
                        Text("Send")
                    }
                    .padding(.trailing)
                }
                .padding()
            }
        }
        .onAppear {
            dump(question)
            if let id = question.id {
                modelData.addMessagesListener(for: id)
            }
        }
    }
    
    private func calculateHeight(geometry: GeometryProxy) {
        let width = geometry.size.width
        let size = CGSize(width: width, height: .infinity)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14)
        ]
        let attributedText = NSAttributedString(string: newMessageContent, attributes: attributes)
        let boundingRect = attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        textHeight = min(boundingRect.height * 0.95 + 20, 200)
    }
    
    private func selectSwiftFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.swiftSource] // .swiftファイルのみを許可
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                do {
                    let fileContents = try String(contentsOf: url, encoding: .utf8)
                    code = fileContents // ファイル内容をcodeに代入
                    fileName = url.lastPathComponent // ファイル名をfileNameに代入
                } catch {
                    print("ファイルの読み込みに失敗しました: \(error)")
                }
            }
        }
    }
    
    private func getRepliedMessage(id: String) -> Message? {
        guard let message = messages.filter({ $0.id == id }).first else {
            return nil
        }
        
        return message
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
