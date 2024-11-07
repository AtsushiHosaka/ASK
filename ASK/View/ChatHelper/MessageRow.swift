//
//  MessageRow.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/15.
//

import SwiftUI
import Splash

struct MessageRow: View {
    var message: Message
    var user: User
    var repliedMessage: Message?
    
    var isMyMessage: Bool {
        return message.sentBy == LoginManager.loadUserUID()
    }
    
    var body: some View {
        if isMyMessage {
            MyMessageContent(message: message, user: user, repliedMessage: repliedMessage)
        } else {
            OthersMessageContent(message: message, user: user, repliedMessage: repliedMessage)
        }
    }
}
