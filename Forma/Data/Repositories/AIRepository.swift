import GoogleGenerativeAI
import Foundation

final class AIRepository: AIRepositoryProtocol {

    private var config: GenerationConfig!
    private var gemini: GenerativeModel!
    private var geminiSingle: GenerativeModel!

    init() {
        buildGemini()
    }

    func generateRoutines(userPreferences: UserPreferences) -> AsyncStream<RoutineBlock> {
        AsyncStream { continuation in
            Task {
                do {
                    try await streamRoutines(userPreferences: userPreferences, continuation: continuation)
                } catch {
                    print(error.localizedDescription)
                }
                continuation.finish()
            }
        }
    }

    private func streamRoutines(userPreferences: UserPreferences, continuation: AsyncStream<RoutineBlock>.Continuation) async throws {
        let stream = gemini.generateContentStream(Constants.prompt(with: userPreferences))
        var buffer = ""

        for try await chunk in stream {
            if let text = chunk.text { buffer += text }

            while let range = buffer.range(of: "Finished") {
                let jsonString = String(buffer[..<range.lowerBound])
                buffer = String(buffer[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)

                if let data = jsonString.data(using: .utf8),
                   let dto = try? JSONDecoder().decode(RoutineDTO.self, from: data) {
                    continuation.yield(dto.toEntity())
                } else {
                    print("Could not decode routine JSON")
                }
            }
        }
    }

    func generateRoutinesEnriched(userPreferences: UserPreferences, answers: [String: AIAnswer]) -> AsyncStream<RoutineBlock> {
        let enriched = buildEnrichedPreferences(base: userPreferences, answers: answers)
        return generateRoutines(userPreferences: enriched)
    }

    func fetchQuestions(userPreferences: UserPreferences) async throws -> AIQuestionsResponse {
        let response = try await geminiSingle.generateContent(Constants.questionsPrompt(with: userPreferences))
        guard let raw = response.text else { throw AIRepositoryError.emptyResponse }
        return try parseQuestions(raw)
    }

    private func buildEnrichedPreferences(base: UserPreferences, answers: [String: AIAnswer]) -> UserPreferences {
        var enriched = base
        for (questionId, answer) in answers {
            guard let label = answer.firstLabel else { continue }
            switch questionId {
            case "work_style": enriched.workStyle = label
            case "exercise": enriched.exerciseTime = label
            case "lunch_break": enriched.lunchBreak = label
            default:
                enriched.additionalContext = (enriched.additionalContext ?? "") + "\(questionId): \(label). "
            }
        }
        return enriched
    }

    private func parseQuestions(_ raw: String) throws -> AIQuestionsResponse {
        let clean = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")

        guard let data = clean.data(using: .utf8) else {
            throw AIRepositoryError.invalidJSON
        }
        return try JSONDecoder().decode(AIQuestionsResponse.self, from: data)
    }

    private func buildGemini() {
        config = GenerationConfig(temperature: 0.7, topP: 0.9, responseMIMEType: "application/json")
        gemini = GenerativeModel(name: Constants.geminiApiModel, apiKey: Constants.geminiApiKey, generationConfig: config)

        let questionConfig = GenerationConfig(temperature: 0.4, topP: 0.9, responseMIMEType: "application/json")
        geminiSingle = GenerativeModel(name: Constants.geminiApiModel, apiKey: Constants.geminiApiKey, generationConfig: questionConfig)
    }
}

enum AIRepositoryError: Error {
    case emptyResponse
    case invalidJSON
}
