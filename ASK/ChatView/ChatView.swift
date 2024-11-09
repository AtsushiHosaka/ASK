//
//  ChatView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import AppKit

struct ChatView: View {
    @ObservedObject var dataManager = DataManager.shared
    @ObservedObject var viewModel = ChatViewModel()
    
    var projectID: String
    var threadID: String
    
    @State private var showAddMemberView: Bool = false
    @State private var showCodeDiff: Bool = false
    @State private var textHeight: CGFloat = 30
    @State private var scrollToMessageID: String? = nil
    
    var project: Project? {
        dataManager.projects.first { $0.id == projectID }
    }
    
    var thread: Thread? {
        project?.threadList.first { $0.id == threadID }
    }
    
    var messages: [Message] {
        thread?.chatMessages ?? []
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.white, .blue.opacity(0.2), .white, .purple.opacity(0.2), .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea(.all)
            
            HStack {
                VStack(alignment: .leading) {
                    messageList
                    
                    Spacer()
                    
                    VStack {
                        if let message = viewModel.replyMessage {
                            HStack {
                                Button(action: viewModel.removeReply) {
                                    Image(systemName: "multiply")
                                        .foregroundStyle(.indigo)
                                        .fontWeight(.bold)
                                }
                                .buttonStyle(ClearBackgroundButtonStyle())
                                
                                Spacer()
                                
                                Text("返信：\(message.content.prefix(30))...")
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
                            if !viewModel.code.isEmpty {
                                CodeView(filePath: viewModel.filePath, code: viewModel.code)
                            }
                            
                            bottomEditorView
                                .padding()
                        }
                    }
                    .padding()
                    .background(.white.opacity(0.3))
                }
                
//                if showAddMemberView {
//                    AddMemberView(project: project)
//                        .frame(width: 300)
//                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
//                        .padding()
//                        .background(.white.opacity(0.3))
//                }
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
//                if let id = question.id {
//                    dataManager.addMessagesListener(for: id)
//                }
            }
        }
    }
    
    var messageList: some View {
        ScrollViewReader { proxy in
            List(messages) { message in
                VStack {
                    if let replyTo = message.replyTo,
                       let repliedMessage = viewModel.getRepliedMessage(messages: messages, id: replyTo) {
                        ReplyRow(message: message)
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                scrollToMessageID = repliedMessage.id
                                proxy.scrollTo(repliedMessage.id, anchor: .top)
                            }
                    }
                    
                    MessageRow(message: message, user: message.sentUser)
                        .listRowSeparator(.hidden)
                        .id(message.id)
                        .contextMenu {
                            Button {
                                viewModel.replyTo(message)
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
        VStack {
            
            HStack {
                TextEditor(text: $viewModel.codeDiffBefore)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 14))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white)
                    )
                    .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                
                Image(systemName: "arrow.forward")
                
                TextEditor(text: $viewModel.codeDiffAfter)
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
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
        }
    }
    
    var bottomEditorView: some View {
        HStack(spacing: 30) {
            TextEditor(text: $viewModel.newMessageContent)
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
                            .onChange(of: viewModel.newMessageContent) {
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
                viewModel.selectSwiftFile()
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
                if !viewModel.newMessageContent.isEmpty {
                    viewModel.newMessage(projectID: projectID, threadID: threadID)
                    showCodeDiff = false
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
    
    private func calculateHeight(geometry: GeometryProxy) {
        let width = geometry.size.width
        let size = CGSize(width: width, height: .infinity)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14)
        ]
        let attributedText = NSAttributedString(string: viewModel.newMessageContent, attributes: attributes)
        let boundingRect = attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        textHeight = min(boundingRect.height * 0.95, 150)
    }
}
