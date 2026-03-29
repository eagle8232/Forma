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
        
        var routineBuffer: [RoutineBlock] = []
        for document in snap.documents {
            let routineDTO = try document.data(as: RoutineDTO.self)
            routineBuffer.append(routineDTO.toEntity())
        }
        
        return routineBuffer
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
