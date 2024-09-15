//
//  SignupView.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/14.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct SignupView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @State private var errorMessage: String?
    @State private var selectedImage: NSImage? // Image picker state
    @State private var imageData: Data?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Spacer()
            
            Text("ASK")
                .font(.custom("HelveticaNeue", size: 60))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
            
            Spacer()
            
            AuthTextField(title: "メールアドレス", text: $email)
            
            AuthSecureField(title: "パスワード", text: $password)
            
            AuthSecureField(title: "パスワード確認", text: $passwordConfirmation)
            
            Button {
                selectImage()
            } label: {
                if let selectedImage = selectedImage {
                    Image(nsImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                }
            }
            .buttonStyle(ClearBackgroundButtonStyle())
            
            Text("アイコンを選択")
                .font(.custom("HelveticaNeue", size: 16))
                .foregroundStyle(.secondary)
                .padding(.top, -20)
            
            Button {
                checkSignup()
            } label: {
                AuthButton(icon: "envelope", text: "アカウント作成")
                    .frame(maxWidth: 300)
            }
            .buttonStyle(ClearBackgroundButtonStyle())
            
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    private func checkSignup() {
        if password == passwordConfirmation {
            Task {
                await signUpWithEmail()
            }
        } else {
            errorMessage = "パスワードが異なります"
        }
    }
    
    // Function to handle image selection
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
    
    // Sign-up function using async/await
    func signUpWithEmail() async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            
            // If image is selected, upload it
            if let imageData = imageData {
                let imageName = try await uploadImage(uid: uid, imageData: imageData)
                await saveUserToFirestore(uid: uid, email: email, imageName: imageName)
            } else {
                await saveUserToFirestore(uid: uid, email: email, imageName: nil)
            }
            
            UserPersistence.saveUser(uid: uid, email: email, password: password)
            
            self.isLoggedIn = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // Function to upload image to Firebase Storage using async/await
    func uploadImage(uid: String, imageData: Data) async throws -> String {
        let storageRef = Storage.storage().reference().child("\(uid).jpg")
        let _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        return "\(uid).jpg"
    }
    
    // Function to save user data to Firestore using async/await
    func saveUserToFirestore(uid: String, email: String, imageName: String?) async {
        let user = User(id: uid, name: email, imageName: imageName ?? "")
        let db = Firestore.firestore()
        
        do {
            try db.collection("users").document(uid).setData(from: user)
        } catch {
            self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
        }
    }
}

#Preview {
    SignupView(isLoggedIn: .constant(false))
}
