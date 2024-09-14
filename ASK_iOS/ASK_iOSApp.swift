//
//  ASK_iOSApp.swift
//  ASK_iOS
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelete: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct ASK_iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelete.self) var delegate
    @StateObject private var modelData = ModelData()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MessageView()
                .environmentObject(modelData)
        }
//        .modelContainer(sharedModelContainer)
    }
}
