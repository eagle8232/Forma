//
//  SaveRoutineUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol SaveRoutineUseCaseProtocol {
    func execute(_ routine: [Routine]) async throws
}

final class SaveRoutineUseCase: SaveRoutineUseCaseProtocol {

    private let repository: RoutineRepositoryProtocol
    
    init(repository: RoutineRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ routine: [Routine]) async throws {
        try await repository.saveRoutine(routine)
    }
}
