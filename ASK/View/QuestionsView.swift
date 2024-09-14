//
//  QuestionsView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI

struct QuestionsView: View {
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(1..<20) { index in
                        ChatBubble(message: "Sample message \(index)")
                    }
                }
                .padding()
            }
            .background(Color.white)
            
            Divider()
            
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    // Send action
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
        }
    }
}

struct ChatBubble: View {
    var message: String
    
    var body: some View {
        HStack {
            Text(message)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            Spacer()
        }
    }
}

#Preview {
    QuestionsView()
}
