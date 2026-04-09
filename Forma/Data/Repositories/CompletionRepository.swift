import Foundation
import FirebaseFirestore

final class CompletionRepository: CompletionRepositoryProtocol {
    
    private let db = Firestore.firestore()
    private let collectionName = "completion_records"
    
    func saveCompletionRecord(_ record: CompletionRecord, userId: String) async throws {
        let dto = record.toDTO()
        
        try db
            .collection(collectionName)
            .document(userId)
            .collection("records")
            .document(record.id)
            .setData(from: dto)
    }
    
    func fetchCompletionRecords(userId: String, from startDate: Date?, to endDate: Date?) async throws -> [CompletionRecord] {
        var query: Query = db
            .collection(collectionName)
            .document(userId)
            .collection("records")
        
        if let startDate = startDate {
            query = query.whereField("date", isGreaterThanOrEqualTo: startDate)
        }
        
        if let endDate = endDate {
            query = query.whereField("date", isLessThan: endDate)
        }
        
        query = query.order(by: "date", descending: true)
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: CompletionRecordDTO.self) else { return nil }
            return dto.toEntity()
        }
    }
    
    func deleteCompletionRecords(userId: String) async throws {
        let snapshot = try await db
            .collection(collectionName)
            .document(userId)
            .collection("records")
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
        
        try await db
            .collection(collectionName)
            .document(userId)
            .delete()
    }
    
    func syncFromFirebase(userId: String) async throws {
        let firebaseRecords = try await fetchCompletionRecords(userId: userId, from: nil, to: nil)
        
        for record in firebaseRecords {
            CoreDataManager.shared.saveCompletionRecord(
                routineId: record.routineId,
                completedTasks: record.completedTasks,
                userId: userId
            )
        }
    }
}
