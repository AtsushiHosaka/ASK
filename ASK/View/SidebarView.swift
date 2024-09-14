//
//  SidebarView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI

struct SidebarView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            List {
                ForEach(1..<20) { index in
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text("[User Name] \(index)")
                                .font(.headline)
                            Text("Last message preview...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(SidebarListStyle())
        }
        .frame(minWidth: 250)
    }
}
