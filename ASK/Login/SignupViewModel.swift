//
//  SignupViewModel.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import SwiftUI
import FirebaseAuth

class SignupViewModel: ObservableObject {
    @ObservedObject var loginManager = LoginManager.shared
    
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var passwordConfirmation = ""
    @Published var errorMessage: String?
    @Published var selectedImage: NSImage?
    @Published var imageData: Data?
    
    func checkSignup() {
        if password == passwordConfirmation {
            Task {
                await signUpWithEmail()
            }
        } else {
            errorMessage = "パスワードが異なります"
        }
    }
    
    func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.begin { response in
            if response == .OK, let url = panel.url, let nsImage = NSImage(contentsOf: url) {
                self.selectedImage = nsImage
                self.imageData = nsImage.tiffRepresentation
            }
        }
    }
    
    func signUpWithEmail() async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            
            if let imageData = imageData {
                let imageName = try await FirebaseStorageAPI.uploadImage(uid: uid, imageData: imageData)
                await FirestoreAPI.saveUserToFirestore(uid: uid, name: name, imageName: imageName)
            } else {
                await FirestoreAPI.saveUserToFirestore(uid: uid, name: name, imageName: nil)
            }
            
            LoginManager.saveUser(uid: uid, email: email, password: password)
            
            self.loginManager.isLoggedIn = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
