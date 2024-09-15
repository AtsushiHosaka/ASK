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
        HStack {
            if !isMyMessage {
                VStack {
                    userIcon
                    Spacer()
                }
            }
            
            VStack(alignment: isMyMessage ? .trailing : .leading) {
                Text(message.content)
                    .frame(maxWidth: .infinity, alignment: isMyMessage ? .trailing : .leading)
                
                if let fileName = message.fileName,
                   let code = message.code {
                    CodeView(fileName: fileName, code: code)
                        .frame(maxWidth: isMyMessage ? 300 : .infinity)
                        .padding()
                }
                
                if let codeDiffBefore = message.codeDiffBefore,
                   let codeDiffAfter = message.codeDiffAfter {
                    CodeDiffView(codeDiffBefore: codeDiffBefore, codeDiffAfter: codeDiffAfter)
                }
            }
            
            if isMyMessage {
                VStack {
                    userIcon
                    Spacer()
                }
            }
        }
    }
    
    var userIcon: some View {
        if let imageData = user.imageData,
           let nsImage = NSImage(data: imageData) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
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
