//
//  ReplyRow.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/15.
//

import SwiftUI

struct ReplyRow: View {
    var message: Message
    
    var isMyMessage: Bool {
        return message.sentBy == UserPersistence.loadUserUID()
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Image(systemName: "arrowshape.turn.up.left.fill")
                .foregroundStyle(.secondary)
                
                
            Text("\(String(message.content.prefix(30)))...")
                .frame(alignment: isMyMessage ? .trailing : .leading)
                .foregroundStyle(.secondary)
                .fontWeight(.bold)
        }
        .padding(.bottom)
    }
}
