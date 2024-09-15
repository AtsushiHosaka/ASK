//
//  AuthTextField.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI

struct AuthTextField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        TextField(title, text: $text)
            .font(.custom("Helvetica Neue", size: 18))
            .frame(maxWidth: 300)
            .padding(.bottom, 8)
            .background(Color.clear)
            .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
            .textFieldStyle(PlainTextFieldStyle())
    }
}
