//
//  RoutineRepository.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation
import FirebaseFirestore

final class RoutineRepository: RoutineRepositoryProtocol {
    
    private let db = Firestore.firestore()
    
    func fetchRoutines(userId: String) async throws -> [RoutineBlock] {
        
        let snap =
        try await db
            .collection(FirestorePathNames.users.rawValue)
            .document(userId)
            .collection(FirestorePathNames.routines.rawValue)
            .getDocuments()
        
        guard let fetchedDocument = snap.documents.first else {
            print("No documents found")
            return []
        }
        
        let routineDTOs = try fetchedDocument.data(as: [RoutineDTO].self)
        let routines = routineDTOs.compactMap{$0.toEntity()}
        
        return routines
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
}
