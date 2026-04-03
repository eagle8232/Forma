import Foundation

protocol AIRepositoryProtocol: AnyObject {
    func generateRoutines(userPreferences: UserPreferences) -> AsyncStream<RoutineBlock>
    func generateRoutinesEnriched(userPreferences: UserPreferences, answers: [String: AIAnswer]) -> AsyncStream<RoutineBlock>
    func fetchQuestions(userPreferences: UserPreferences) async throws -> AIQuestionsResponse
}
