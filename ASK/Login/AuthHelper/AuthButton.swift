//
//  AuthButton.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI

struct AuthButton: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .fontWeight(.heavy)
                .foregroundColor(.white)
            
            Text(text)
                .font(.custom("HelveticaNeue", size: 18))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .fontWeight(.heavy)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(.indigo)
                .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.init(white: 1, opacity: 0.5), lineWidth: 1)
        )
    }
}

struct ClearBackgroundButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.clear)
            .cornerRadius(0)
    }
}
