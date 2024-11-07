//
//  EditorButtonLabel.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI

struct EditorButtonLabel: View {
    var imageName: String
    
    var body: some View {
        Image(systemName: imageName)
            .foregroundColor(.indigo)
            .fontWeight(.heavy)
            .padding()
            .background(
                Circle()
                    .fill(Color.white)
                    .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
            )
    }
}
