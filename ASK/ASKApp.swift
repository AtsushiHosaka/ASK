//
//  ASKApp.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import FirebaseCore

//class AppDelegate: NSObject, NSApplicationDelegate {
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        // Initialize Firebase
//    }
//}

@main
struct ASKApp: App {
    init() {
        FirebaseApp.configure()
    }
    
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var modelData = ModelData()

    var body: some Scene {
        WindowGroup {
            MessageView()
                .environmentObject(modelData)
        }
    }
}
