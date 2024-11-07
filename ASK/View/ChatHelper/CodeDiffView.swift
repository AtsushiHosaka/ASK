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
        HStack(spacing: 30) {
            VStack(alignment: .leading) {
                ForEach(Array(linesBefore.enumerated()), id: \.element) { index, line in
                    Text(AttributedString(highlighter.highlight(line)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .background(
                            Rectangle()
                                .fill(deletedRows.contains(index + 1) ? Color(red: 252 / 255, green: 236 / 255, blue: 234 / 255) : Color.clear)
                        )
                }
            }
            
            Image(systemName: "arrow.forward")
                .fontWeight(.heavy)
            
            VStack(alignment: .leading) {
                ForEach(Array(linesAfter.enumerated()), id: \.element) { index, line in
                    Text(AttributedString(highlighter.highlight(line)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .background(
                            Rectangle()
                                .fill(addedRows.contains(index + 1) ? Color(red: 224 / 255, green: 250 / 255, blue: 227 / 255) : Color.clear)
                        )
                }
            }
        }
        .onAppear {
            compareStrings()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)
                .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
        )
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
}
