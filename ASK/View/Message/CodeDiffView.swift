//
//  CodeDiffView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI
import Splash

struct CodeDiffView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var theme: Theme {
        colorScheme == .light ? .presentation(withFont: Font(size: 14)) : .midnight(withFont: Font(size: 14))
    }
    var highlighter: SyntaxHighlighter<AttributedStringOutputFormat> {
        SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme))
    }
    
    var codeDiffBefore: String
    var codeDiffAfter: String
    
    var linesBefore: [String] {
        codeDiffBefore.components(separatedBy: .newlines)
    }
    var linesAfter: [String] {
        codeDiffAfter.components(separatedBy: .newlines)
    }
    
    @State var deletedRows: [Int] = []
    @State var addedRows: [Int] = []
    
    var body: some View {
        HStack {
            
            ZStack {
                VStack(alignment: .leading) {
                    ForEach(Array(linesBefore.enumerated()), id: \.element) { index, line in
                        Text(AttributedString(highlighter.highlight(line)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(1)
                            .background(deletedRows.contains(index + 1) ? Color.red : Color.clear)
                    }
                }
            }
            
            Image(systemName: "arrow.forward")
            
            ZStack {
                VStack(alignment: .leading) {
                    ForEach(Array(linesAfter.enumerated()), id: \.element) { index, line in
                        Text(AttributedString(highlighter.highlight(line)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(1)
                            .background(addedRows.contains(index + 1) ? Color.green : Color.clear)
                    }
                }
            }
        }
        .onAppear {
            compareStrings()
        }
        .padding()
    }
    
    private func backgroundColor(rowNumber: Int) -> SwiftUI.Color {
        if deletedRows.contains(rowNumber) {
            return Color.red
        } else if addedRows.contains(rowNumber) {
            return Color.green
        }
        
        return Color.clear
    }
    
    private func compareStrings() {
        deletedRows = []
        addedRows = []
        
        for (index, line) in linesBefore.enumerated() {
            if !linesAfter.contains(line) {
                deletedRows.append(index + 1)
            }
        }
        
        for (index, line) in linesAfter.enumerated() {
            if !linesBefore.contains(line) {
                addedRows.append(index + 1)
            }
        }
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
}

#Preview {
    let oldText = """
    let a = 100
    let b = 10
    """
    
    let newText = """
    let a = 100
    let c = 1
    """
    
    return CodeDiffView(codeDiffBefore: oldText, codeDiffAfter: newText)
}
