//
//  QuestionRow.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

//import SwiftUI

//struct QuestionRow: View {
//    var question: Question
//    
//    var title: String {
//        if let messages = question.messages {
//            if let lastMessage = messages.last {
//                print(lastMessage.content)
//                return String(lastMessage.content.prefix(15))
//            }
//        }
//        
//        return ""
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.headline)
//            Text("\(question.createDate, formatter: dateFormatter)に作成")
//                .font(.subheadline)
//        }
//        .padding()
//    }
//    
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        return formatter
//    }
//}
