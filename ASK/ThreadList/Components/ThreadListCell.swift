//
//  ThreadListCell.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import SwiftUI

struct ThreadListCell: View {
    var thread: Thread
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding(.leading, 20)
            
            VStack(alignment: .leading) {
                Text(thread.errorMessage)
                    .foregroundStyle(.primary)
                Text("by aaaaa")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack {
                Text("3分前")
                    .foregroundStyle(.secondary)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.5).cornerRadius(10))
    }
}
