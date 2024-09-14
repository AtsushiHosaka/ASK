//
//  MessageView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI

struct MessageView: View {
    var question: Question
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Question: \(question.title)")
                .font(.headline)
            Text("Created on: \(question.createDate, formatter: dateFormatter)")
                .font(.subheadline)
            
            if let member = question.member {
                ForEach(member) { user in
                    if let userId = user.id {  // Userのidをアンラップ
                        HStack {
                            Text("User: \(user.name)")
                            Text("ID: \(userId)")
                        }
                    }
                }
            }
            ForEach(question.memberID, id: \.self) { user in
                Text(user)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    MessageView(question: Question(title: "テスト", createDate: Date(), memberID: ["as", "atsushi"]))
        .environmentObject(ModelData())
}
