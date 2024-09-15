//
//  OthersMessageContent.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI

struct OthersMessageContent: View {
    var message: Message
    var user: User
    var repliedMessage: Message?
    
    var body: some View {
        HStack {
            VStack {
                UserIcon(user: user)
                Spacer()
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(message.content)
                        .font(.custom("Helvetica Neue", size: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.5))
                        )
                    
                    Spacer()
                }
                
                if let fileName = message.fileName,
                   let code = message.code {
                    CodeView(fileName: fileName, code: code)
                        .frame(maxWidth: .infinity)
                }
                
                if let codeDiffBefore = message.codeDiffBefore,
                   let codeDiffAfter = message.codeDiffAfter {
                    CodeDiffView(codeDiffBefore: codeDiffBefore, codeDiffAfter: codeDiffAfter)
                }
            }
        }
    }
}
