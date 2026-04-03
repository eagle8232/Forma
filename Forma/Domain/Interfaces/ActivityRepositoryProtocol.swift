import Foundation

protocol ActivityRepositoryProtocol {
    func fetchActivities(with id: String) async throws -> [RoutineTask]
    func saveActivity(_ activity: RoutineTask) async throws
    func deleteActivity(_ activity: RoutineTask) async throws
}
