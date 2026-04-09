import Foundation

protocol CompletionRepositoryProtocol {
    func saveCompletionRecord(_ record: CompletionRecord, userId: String) async throws
    func fetchCompletionRecords(userId: String, from: Date?, to: Date?) async throws -> [CompletionRecord]
    func deleteCompletionRecords(userId: String) async throws
    func syncFromFirebase(userId: String) async throws
}
