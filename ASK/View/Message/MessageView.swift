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
    @State private var replyMessage: Message? = nil
    @State private var showCodeDiff: Bool = false
    @State private var codeDiffBefore: String = ""
    @State private var codeDiffAfter: String = ""
    
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
                        .contextMenu {
                            Button(action: {
                                replyTo(message)
                            }) {
                                Text("返信する")
                            }
                        }
                }
            }
            
            Spacer()
            
            if let replyMessage {
                HStack {
                    Spacer()
                    
                    Text("返信：\(replyMessage.content.prefix(30))...")
                        .foregroundStyle(.secondary)
                    
                    Button(action: removeReply) {
                        Image(systemName: "multiply.circle")
                    }
                }
            }
            
            if showCodeDiff {
                HStack {
                    TextEditor(text: $codeDiffBefore)
                        .font(.system(size: 14))
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
                    
                    Image(systemName: "arrow.forward")
                    
                    TextEditor(text: $codeDiffAfter)
                        .font(.system(size: 14))
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
                    
                    Button {
                        showCodeDiff = false
                    } label: {
                        Image(systemName: "multiply.circle")
                    }
                    .padding()
                }
                .frame(height: 200)
                .padding()
            }
            
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
                    
                    Button {
                        showCodeDiff = true
                    } label: {
                        Text("Code Diff")
                    }
                    .padding()
                    
                    Button(action: {
                        selectSwiftFile()
                    }) {
                        Text("Select File")
                    }
                    .padding()
                    
                    Button(action: {
                        var newMessage = Message(date: Date(), content: newMessageContent, sentBy: UserPersistence.loadUserUID()!)
                        
                        if let replyMessage {
                            newMessage.replyTo = replyMessage.id
                        }
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
                        replyMessage = nil // 返信先をクリア
                    }) {
                        Text("Send")
                    }
                    .padding()
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
    
    private func replyTo(_ message: Message) {
        replyMessage = message
        codeDiffBefore = message.code ?? ""
    }
    
    private func removeReply() {
        replyMessage = nil
    }
    
    private func calculateHeight(geometry: GeometryProxy) {
        let width = geometry.size.width
        let size = CGSize(width: width, height: .infinity)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14)
        ]
        let attributedText = NSAttributedString(string: newMessageContent, attributes: attributes)
        let boundingRect = attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        textHeight = min(boundingRect.height * 0.95 + 20, 150)
    }
    
    private func selectSwiftFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.swiftSource]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                do {
                    let fileContents = try String(contentsOf: url, encoding: .utf8)
                    code = fileContents
                    fileName = url.lastPathComponent
                } catch {
                    print("ファイルの読み込みに失敗しました: \(error)")
                }
            }
        }
    }
    
    private func getRepliedMessage(id: String) -> Message? {
        guard let message = messages.first(where: { $0.id == id }) else {
            return nil
        }
        return message
    }
}

#Preview {
    MessageView(question: Question(title: "テスト", createDate: Date(), memberID: ["as", "atsushi"], messages: []))
        .environmentObject(ModelData())
}
