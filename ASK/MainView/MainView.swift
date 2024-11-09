//
//  MainView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/11/07.
//

import FirebaseAuth
import SwiftUI

struct MainView: View {
    @ObservedObject var dataManager = DataManager.shared
    @ObservedObject var loginManager = LoginManager.shared

    @State private var initialLoaded = false
    @State private var showingAlert = false
    
    @State private var selectedProjectID: String?
    
    var selectedProject: Project? {
        dataManager.projects.first { $0.id == selectedProjectID }
    }

    var body: some View {
        NavigationSplitView {
            HStack(alignment: .center){
                VStack {
                    Image(systemName: "bubble.left.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Spacer()
                    
                    UserIcon(user: loginManager.currentUser)
                        .frame(width: 20, height: 20)
                }
                .padding()
            }
            .navigationSplitViewColumnWidth(75)
        } detail: {
            ZStack {
                #if os(iOS)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white, .blue.opacity(0.2), .white,
                            .purple.opacity(0.2), .white,
                        ]), startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea(.all)
                #endif

                if dataManager.isLoading {
                    ProgressView("Loading...")
                } else {
                    HStack {
                        ProjectList(selectedProjectID: $selectedProjectID)
                                                .frame(width: 300)
                        
                        Divider()
                        
                        if let selectedProjectID {
                            ThreadList(projectID: selectedProjectID)
                        } else {
                            Spacer()
                        }
                    }
                    .onAppear {
                        if !initialLoaded {
                            Task {
                                if dataManager.projects.isEmpty {
                                    await dataManager.addProjectsListener()
                                    initialLoaded = true
                                }
                            }
                        }
                    }
                }
            }
            #if os(macOS)
            .toolbar(.hidden)
            #endif
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            LoginManager.clearUser()
            loginManager.isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
