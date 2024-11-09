//
//  CodeView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/15.
//

import SwiftUI
import Splash

struct CodeView: View {
    var filePath: String
    var code: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var theme: Theme {
        colorScheme == .light ? .presentation(withFont: Font(size: 14)) : .midnight(withFont: Font(size: 14))
    }
    var highlighter: SyntaxHighlighter<AttributedStringOutputFormat> {
        SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            Text(filePath)
                .padding(.leading, 10)
            ScrollView([.horizontal, .vertical]) {
                    Text(AttributedString(highlighter.highlight(code)))
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
            }
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
            )
            .frame(maxHeight: 300)
        }
        .padding()
    }
}
