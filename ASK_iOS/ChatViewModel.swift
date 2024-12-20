//
//  ChatViewModel.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var newMessageContent: String = ""
    @Published var fileName: String = ""
    @Published var code: String = ""
    @Published var replyMessage: Message? = nil
    @Published var codeDiffBefore: String = ""
    @Published var codeDiffAfter: String = ""
    
    func newMessage(question: Question) {
        var tempMessage = Message(date: Date(), content: newMessageContent, sentBy: LoginManager.loadUserUID()!)
            
        if !code.isEmpty {
            tempMessage.fileName = fileName
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
            try await FirestoreAPI.addMessageToFirestore(question: question, message: newMessage)
        }
        
        newMessageContent = ""
        fileName = ""
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
    
    func getRepliedMessage(messages: [Message], id: String) -> Message? {
        guard let message = messages.first(where: { $0.id == id }) else {
            return nil
        }
        return message
    }
}
