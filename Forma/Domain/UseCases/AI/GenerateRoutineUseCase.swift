//
//  GenerateRoutineUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/7/26.
//

import Foundation

protocol GenerateRoutineUseCaseProtocol {
    func execute(userPreferences: UserPreferences) async throws -> AsyncStream<RoutineBlock>
}

final class GenerateRoutineUseCase: GenerateRoutineUseCaseProtocol {

    private let aiRepository: AIRepositoryProtocol
    
    init(aiRepository: AIRepositoryProtocol) {
        self.aiRepository = aiRepository
    }
    
    func execute(userPreferences: UserPreferences) async throws -> AsyncStream<RoutineBlock> {
        try await aiRepository.generateRoutines(userPreferences: userPreferences)
    }
}
