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
    
    func fetchRoutines(userId: String) async throws -> [Routine] {
        
        let snap =
        try await db
            .collection("users")
            .document(userId)
            .collection("routines")
            .getDocuments()
        
        guard let fetchedDocument = snap.documents.first else {
            print("No documents found")
            return []
        }
        
        let routineDTOs = try fetchedDocument.data(as: [RoutineDTO].self)
        let routines = routineDTOs.compactMap{$0.toEntity()}
        
        return routines
    }
    
    func saveRoutine(_ routines: [Routine], userId: String) async throws {
        
        for routine in routines {
            let routineDTO = routine.toDTO()
            try db
                .collection("users")
                .document(userId)
                .collection("routines")
                .document(routine.id)
                .setData(from: routineDTO)
        }
        
    }
    
    func deleteRoutine(_ routine: Routine, userId: String) async throws {
        
        try await db
            .collection("users")
            .document(userId)
            .collection("routines")
            .document(routine.id).delete()
        
    }
}
