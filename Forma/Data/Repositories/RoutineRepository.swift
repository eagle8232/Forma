import Foundation
import FirebaseFirestore

final class RoutineRepository: RoutineRepositoryProtocol {
    
    private let db = Firestore.firestore()
    
    func fetchRoutines(userId: String) async throws -> [RoutineBlock] {
        let snap = try await db
            .collection(FirestorePathNames.users.rawValue)
            .document(userId)
            .collection(FirestorePathNames.routines.rawValue)
            .getDocuments()
        
        return snap.documents.compactMap { document in
            try? document.data(as: RoutineDTO.self).toEntity()
        }
    }
    
    func saveRoutine(_ routines: [RoutineBlock], userId: String) async throws {
        for routine in routines {
            let routineDTO = routine.toDTO()
            try db
                .collection(FirestorePathNames.users.rawValue)
                .document(userId)
                .collection(FirestorePathNames.routines.rawValue)
                .document(routine.id)
                .setData(from: routineDTO)
        }
    }
    
    func deleteRoutine(_ routine: RoutineBlock, userId: String) async throws {
        try await db
            .collection(FirestorePathNames.users.rawValue)
            .document(userId)
            .collection(FirestorePathNames.routines.rawValue)
            .document(routine.id).delete()
    }
    
    func deleteAllRoutines(userId: String) async throws {
        let snap = try await db
            .collection(FirestorePathNames.users.rawValue)
            .document(userId)
            .collection(FirestorePathNames.routines.rawValue)
            .getDocuments()
        
        for document in snap.documents {
            try await document.reference.delete()
        }
    }
}
