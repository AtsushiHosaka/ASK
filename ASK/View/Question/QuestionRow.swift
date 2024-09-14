//
//  QuestionRow.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI

struct QuestionRow: View {
    var question: Question
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(question.title)
                .font(.headline)
            Text("Created on: \(question.createDate, formatter: dateFormatter)")
                .font(.subheadline)
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
    QuestionRow(question: Question(title: "テスト", createDate: Date(), memberID: ["as", "atsushi"], messages: []))
}
