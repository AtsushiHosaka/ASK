//
//  ChatView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import AppKit

struct ChatView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showAddMemberView: Bool = false
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
        HStack {
            VStack(alignment: .leading) {
                messageList
                
                Spacer()
                
                VStack {
                    if let replyMessage {
                        HStack {
                            Button(action: removeReply) {
                                Image(systemName: "multiply")
                                    .foregroundStyle(.indigo)
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(ClearBackgroundButtonStyle())
                            
                            Spacer()
                            
                            Text("返信：\(replyMessage.content.prefix(30))...")
                                .foregroundStyle(.secondary)
                                .fontWeight(.bold)
                        }
                    }
                    
                    if showCodeDiff {
                        codeDiffEditor
                            .frame(height: 200)
                            .padding()
                    }
                    
                    VStack {
                        if !code.isEmpty {
                            CodeView(fileName: fileName, code: code)
                        }
                        
                        bottomEditorView
                            .padding()
                    }
                }
                .padding()
                .background(.white.opacity(0.3))
            }
            
            if showAddMemberView {
                AddMemberView(question: question)
                    .frame(width: 300)
                    .transition(.move(edge: .trailing))
                    .padding()
                    .background(.white.opacity(0.3))
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    withAnimation {
                        showAddMemberView.toggle()
                    }
                }) {
                    Image(systemName: "person.fill.badge.plus")
                        .imageScale(.large)
                }
            }
        }
        .onAppear {
            if let id = question.id {
                modelData.addMessagesListener(for: id)
            }
        }
    }
    
    var messageList: some View {
        ScrollViewReader { proxy in
            List(messages) { message in
                VStack {
                    if let replyTo = message.replyTo,
                       let repliedMessage = getRepliedMessage(id: replyTo) {
                        ReplyRow(message: message)
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                scrollToMessageID = repliedMessage.id
                                proxy.scrollTo(repliedMessage.id, anchor: .top)
                            }
                    }
                    
                    MessageRow(message: message, user: question.member!.first(where: { $0.id == message.sentBy })!)
                        .listRowSeparator(.hidden)
                        .id(message.id)
                        .contextMenu {
                            Button {
                                replyTo(message)
                            } label: {
                                Text("返信する")
                            }
                        }
                }
                .listRowSeparator(.hidden)
                .padding(.vertical)
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    var codeDiffEditor: some View {
        HStack {
            TextEditor(text: $codeDiffBefore)
                .scrollContentBackground(.hidden)
                .font(.system(size: 14))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white)
                )
                .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
            
            Image(systemName: "arrow.forward")
            
            TextEditor(text: $codeDiffAfter)
                .scrollContentBackground(.hidden)
                .font(.system(size: 14))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white)
                )
                .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
            
            Button {
                showCodeDiff = false
            } label: {
                Image(systemName: "multiply.circle")
            }
            .padding()
        }
    }
    
    var bottomEditorView: some View {
        HStack(spacing: 30) {
            TextEditor(text: $newMessageContent)
                .scrollContentBackground(.hidden)
                .font(.system(size: 14))
                .frame(height: max(30, textHeight))
                .padding()
                .background(
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)
                            .onAppear {
                                calculateHeight(geometry: geometry)
                            }
                            .onChange(of: newMessageContent) {
                                calculateHeight(geometry: geometry)
                            }
                    }
                )
                .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
            
            Button {
                withAnimation {
                    showCodeDiff.toggle()
                }
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(.indigo)
                    .fontWeight(.heavy)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                    )
            }
            .frame(width: 30, height: 30)
            .buttonStyle(ClearBackgroundButtonStyle())
            
            
            Button {
                selectSwiftFile()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.indigo)
                    .fontWeight(.heavy)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                    )
            }
            .frame(width: 30, height: 30)
            .buttonStyle(ClearBackgroundButtonStyle())
            
            Button {
                if !newMessageContent.isEmpty {
                    newMessage()
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .fontWeight(.heavy)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.indigo)
                            .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                    )
            }
            .frame(width: 30, height: 30)
            .buttonStyle(ClearBackgroundButtonStyle())
            
        }
    }
    
    private func newMessage() {
        var newMessage = Message(date: Date(), content: newMessageContent, sentBy: UserPersistence.loadUserUID()!)
        
        if !code.isEmpty {
            newMessage.fileName = fileName
            newMessage.code = code
        }
        
        if !codeDiffBefore.isEmpty, !codeDiffAfter.isEmpty {
            newMessage.codeDiffBefore = codeDiffBefore
            newMessage.codeDiffAfter = codeDiffAfter
        }
        
        if let replyMessage {
            newMessage.replyTo = replyMessage.id
        }
        
        Task {
            try await FirestoreAPI.addMessageToFirestore(question: question, message: newMessage)
        }
        newMessageContent = ""
        fileName = ""
        code = ""
        replyMessage = nil
        showCodeDiff = false
        codeDiffBefore = ""
        codeDiffAfter = ""
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
        textHeight = min(boundingRect.height * 0.95, 150)
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
    ChatView(question: Question(title: "テスト", createDate: Date(), memberID: ["as", "atsushi"], messages: []))
        .environmentObject(ModelData())
}
