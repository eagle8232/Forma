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
        
        return try document.data(as: UserDTO.self).toEntity()
    }
    
    func saveUser(_ user: User) async throws {
        let userDTO = user.toDTO()
        try db
            .collection(FirestorePathNames.users.rawValue)
            .document(user.credentials.id)
            .collection(FirestorePathNames.preferences.rawValue)
            .addDocument(from: userDTO)
    }
    
    func deleteUser(_ user: User) async throws {
        try await db
            .collection(FirestorePathNames.users.rawValue)
            .document(user.credentials.id).delete()
    }
}
