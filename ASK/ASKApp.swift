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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
