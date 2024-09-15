//
//  MessageRow.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/15.
//

import SwiftUI
import Splash

struct MessageRow: View {
    let a = 12345
    let code: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var theme: Theme {
        colorScheme == .light ? .presentation(withFont: Font(size: 14)) : .midnight(withFont: Font(size: 14))
    }
    var highlighter: SyntaxHighlighter<AttributedStringOutputFormat> {
        SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            Text("title.swift")
                .padding(.leading, 10)
            ScrollView([.horizontal, .vertical]) {
                Text(AttributedString(highlighter.highlight(code)))
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 2)
                    .foregroundColor(.gray)
            )
            .frame(maxHeight: 300)
        }
        .padding()
    }
    
    
    let lightTheme = Theme(
        font: Font(size: 14),
        plainTextColor: NSColor(.primary),
        tokenColors: [
            .keyword: NSColor.purple,
            .string: NSColor(red: 196 / 255, green: 26 / 255, blue: 22 / 255, alpha: 1.0),
            .type: NSColor(red: 11 / 255, green: 79 / 255, blue: 121 / 255, alpha: 1.0),
            .call: NSColor(red: 50 / 255, green: 109 / 255, blue: 116 / 255, alpha: 1.0),
            .number: NSColor.blue,
            .comment: NSColor(red: 93 / 255, green: 108 / 255, blue: 121 / 255, alpha: 1.0),
            .property: NSColor(red: 50 / 255, green: 109 / 255, blue: 116 / 255, alpha: 1.0),
            .dotAccess: NSColor(red: 108 / 255, green: 54 / 255, blue: 169 / 255, alpha: 1.0),
            .preprocessing: NSColor(red: 100 / 255, green: 56 / 255, blue: 32 / 255, alpha: 1.0)
        ]
    )
    
    let darkTheme = Theme(
        font: Font(size: 14),
        plainTextColor: NSColor(.primary),
        tokenColors: [
            .keyword: NSColor(red: 252 / 255, green: 95 / 255, blue: 163 / 255, alpha: 1.0),
            .string: NSColor(red: 252 / 255, green: 106 / 255, blue: 93 / 255, alpha: 1.0),
            .type: NSColor(red: 93 / 255, green: 216 / 255, blue: 255 / 255, alpha: 1.0),
            .call: NSColor(red: 50 / 255, green: 109 / 255, blue: 116 / 255, alpha: 1.0),
            .number: NSColor.blue,
            .comment: NSColor(red: 93 / 255, green: 108 / 255, blue: 121 / 255, alpha: 1.0),
            .property: NSColor(red: 50 / 255, green: 109 / 255, blue: 116 / 255, alpha: 1.0),
            .dotAccess: NSColor(red: 108 / 255, green: 54 / 255, blue: 169 / 255, alpha: 1.0),
            .preprocessing: NSColor(red: 100 / 255, green: 56 / 255, blue: 32 / 255, alpha: 1.0)
        ]
    )
}

#Preview {
    MessageRow(
        code:  """
        import SwiftUI
        
        struct ContentView: View {
            let a = 12345
            
            var body: some View {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    Text("Hello, world!")
                }
            }
        }
        """
    )
}
