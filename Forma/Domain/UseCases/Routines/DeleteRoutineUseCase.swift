//
//  DeleteRoutineUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol DeleteRoutineUseCaseProtocol {
    func execute(_ routine: RoutineBlock, userId: String) async throws
}

final class DeleteRoutineUseCase: DeleteRoutineUseCaseProtocol {
     
    private let repository: RoutineRepositoryProtocol
    
    init(repository: RoutineRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ routine: RoutineBlock, userId: String) async throws {
        try await repository.deleteRoutine(routine, userId: userId)
    }
}
