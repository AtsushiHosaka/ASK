//
//  MessageView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var modelData: ModelData
    
    var question: Question
    @State private var newMessageContent: String = ""
    @State private var textHeight: CGFloat = 30
    
    var body: some View {
        VStack(alignment: .leading) {
            List(question.messages) { message in
                Text(message.content)
            }
            
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
        textHeight = max(boundingRect.height * 0.95 + 20, 200)
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
