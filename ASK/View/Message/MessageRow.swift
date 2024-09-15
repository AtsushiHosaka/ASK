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
    var repliedMessage: Message?
    
    var isMyMessage: Bool {
        return message.sentBy == UserPersistence.loadUserUID()
    }
    
    var body: some View {
        VStack(alignment: isMyMessage ? .trailing : .leading) {
            Text(message.content)
                .frame(maxWidth: .infinity, alignment: isMyMessage ? .trailing : .leading)
            
            if let fileName = message.fileName,
               let code = message.code {
                CodeView(fileName: fileName, code: code)
                    .frame(maxWidth: isMyMessage ? 300 : .infinity)
                    .padding()
            }
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
