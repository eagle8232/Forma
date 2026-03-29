//
//  AIRepository.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/7/26.
//

import GoogleGenerativeAI
import Foundation

final class AIRepository: AIRepositoryProtocol {
    
    private var config: GenerationConfig!
    private var gemini: GenerativeModel!
    
    init() {
        buildGemini()
    }
    
    func generateRoutines(userPreferences: UserPreferences) -> AsyncStream<RoutineBlock> {
        AsyncStream { continuation in
            Task {
                do {
                    try await streamRoutines(userPreferences: userPreferences, continuation: continuation)
                } catch let err {
                    print(err.localizedDescription)
                }
                continuation.finish()
            }
        }
    }
    
    func streamRoutines(userPreferences: UserPreferences, continuation: AsyncStream<RoutineBlock>.Continuation ) async throws {
        
        let stream = gemini.generateContentStream(Constants.prompt(with: userPreferences))
        var buffer: String = ""
        
        for try await chunk in stream {
            if let newText = chunk.text {
                buffer += newText
            }
            while let range = buffer.range(of: "Finished") {
                let jsonString = String(buffer[..<range.lowerBound])
                buffer = String(buffer[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                print(buffer)
                
                if let bufferData = jsonString.data(using: .utf8),
                   let routineDTO = try? JSONDecoder().decode(RoutineDTO.self, from: bufferData) {
                    continuation.yield(routineDTO.toEntity())
                } else {
                    print("Could not decode JSON string")
                }
            }
        }
        
    }
    
    func summarize () {
        
    }
    
    // MARK: - Private Methods
    
    private func buildGemini() {
        config = GenerationConfig(
            temperature: 0.7,
            topP: 0.9,
            responseMIMEType: "application/json"
        )
        gemini = GenerativeModel(
            name: Constants.geminiApiModel,
            apiKey: Constants.geminiApiKey,
            generationConfig: config
        )
    }
}
