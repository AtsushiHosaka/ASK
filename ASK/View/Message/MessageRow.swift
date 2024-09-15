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
        return message.sentBy == UserPersistence.loadUserUID()
    }
    
    var body: some View {
        if isMyMessage {
            MyMessageContent(message: message, user: user, repliedMessage: repliedMessage)
        } else {
            OthersMessageContent(message: message, user: user, repliedMessage: repliedMessage)
        }
    }
}

//#Preview {
//    MessageRow(
//        code:  """
//        import SwiftUI
//
//        struct ContentView: View {
//            let a = 12345
//
//            var body: some View {
//                VStack {
//                    Image(systemName: "globe")
//                        .imageScale(.large)
//                        .foregroundColor(.accentColor)
//                    Text("Hello, world!")
//                }
//            }
//        }
//        """
//    )
//}
