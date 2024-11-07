//
//  FirebaseStorageAPI.swift
//  ASK
//
//  Created by 保坂篤志 on 2024/09/16.
//

import Foundation
import FirebaseStorage

class FirebaseStorageAPI {
    static private let storage = Storage.storage().reference()
    
    static func fetchImageData(from imageName: String) async -> Data? {
        let storageRef = storage.child("\(imageName)")
        
        do {
            let imageData = try await storageRef.data(maxSize: 5 * 1024 * 1024)
            
            return imageData
        } catch {
            return nil
        }
    }
    
    static func uploadImage(uid: String, imageData: Data) async throws -> String {
        let storageRef = storage.child("\(uid).jpg")
        let _ = try await storageRef.putDataAsync(imageData)
        return "\(uid).jpg"
    }
}
