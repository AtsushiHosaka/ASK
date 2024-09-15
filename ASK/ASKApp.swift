//
//  ASKApp.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import FirebaseCore

@main
struct ASKApp: App {
    init() {
        FirebaseApp.configure()
    }

    @StateObject private var modelData = ModelData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
