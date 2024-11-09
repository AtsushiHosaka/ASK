//
//  ChatViewModel.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var newMessageContent: String = ""
    @Published var filePath: String = ""
    @Published var code: String = ""
    @Published var replyMessage: Message? = nil
    @Published var codeDiffBefore: String = ""
    @Published var codeDiffAfter: String = ""
    
    func newMessage(projectID: String, threadID: String) {
        var tempMessage = Message(date: Date(), content: newMessageContent, sentBy: LoginManager.loadUserUID()!)
            
        if !code.isEmpty {
            tempMessage.filePath = filePath
            tempMessage.code = code
        }
        
        if !codeDiffBefore.isEmpty, !codeDiffAfter.isEmpty {
            tempMessage.codeDiffBefore = codeDiffBefore
            tempMessage.codeDiffAfter = codeDiffAfter
        }
        
        if let replyMessage {
            tempMessage.replyTo = replyMessage.id
        }
        
        let newMessage = tempMessage
        
        Task {
            try await FirestoreAPI.addMessageToFirestore(projectID: projectID, threadID: threadID, message: newMessage)
        }
        
        newMessageContent = ""
        filePath = ""
        code = ""
        replyMessage = nil
        codeDiffBefore = ""
        codeDiffAfter = ""
    }
    
    func replyTo(_ message: Message) {
        replyMessage = message
        codeDiffBefore = message.code ?? ""
    }
    
    func removeReply() {
        replyMessage = nil
    }
    
    func selectSwiftFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.swiftSource]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                do {
                    let fileContents = try String(contentsOf: url, encoding: .utf8)
                    code = fileContents
                    filePath = url.lastPathComponent
                } catch {
                    print("ファイルの読み込みに失敗しました: \(error)")
                }
            }
        }
    }
    
    func getRepliedMessage(messages: [Message], id: String) -> Message? {
        guard let message = messages.first(where: { $0.id == id }) else {
            return nil
        }
        return message
    }
}
