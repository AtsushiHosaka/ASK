//
//  ThreadView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import SwiftUI

struct ThreadView: View {
    @Environment(\.dismiss) var dismiss
    
    var thread: Thread
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                
                VStack(alignment: .leading) {
                    Text(thread.errorMessage)
                        .foregroundStyle(.primary)
                    
                    Text("○分前")
                }
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image(systemName: "text.and.command.macwindow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                
                Button(action: {
                    
                }) {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
            }
            .frame(height: 75)
            
            Spacer()
        }
    }
}
