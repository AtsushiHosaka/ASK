//
//  MessageView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI

struct MessageView: View {
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(1..<3) { item in
                    NavigationLink {
                        
                    } label: {
                        
                    }
                }
//                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
}

#Preview {
    MessageView()
}
