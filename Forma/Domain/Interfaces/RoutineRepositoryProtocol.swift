import Foundation

protocol RoutineRepositoryProtocol {
    func fetchRoutines(userId: String) async throws -> [RoutineBlock]
    func saveRoutine(_ routines: [RoutineBlock], userId: String) async throws
    func deleteRoutine(_ routine: RoutineBlock, userId: String) async throws
    func deleteAllRoutines(userId: String) async throws
}
