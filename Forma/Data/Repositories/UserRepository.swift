//
//  UserRepository.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/9/26.
//

import Foundation
import FirebaseFirestore

final class UserRepository: UserRepositoryProtocol {
    
    private let db = Firestore.firestore()
    
    func fetchUser(_ userId: String) async throws -> User? {
        
        guard let document = try await db
            .collection(FirestorePathNames.users.rawValue)
            .document(userId)
            .collection(FirestorePathNames.preferences.rawValue)
            .getDocuments().documents.first else {
            return nil
        }
        
        let userDTO = try document.data(as: UserDTO.self)
        let user = userDTO.toEntity()
        
        return user
    }
    
    func saveUser(_ user: User) async throws {
        
        let userDTO = user.toDTO()
        let collection = db
            .collection(FirestorePathNames.users.rawValue)
            .document(user.userCredentials.id)
            .collection(FirestorePathNames.preferences.rawValue)
        try collection.addDocument(from: userDTO)
    }
    
    func deleteUser(_ user: User) async throws {
        
        try await db
            .collection(FirestorePathNames.users.rawValue)
            .document(user.userCredentials.id).delete()
    }
}
