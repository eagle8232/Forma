//
//  RoutineUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol FetchRoutinesUseCaseProtocol {
    func execute(userId: String) async throws -> [RoutineBlock]
}

final class FetchRoutinesUseCase: FetchRoutinesUseCaseProtocol {
    
    private let repository: RoutineRepositoryProtocol
    
    init(repository: RoutineRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(userId: String) async throws -> [RoutineBlock] {
        
        let routines = try await repository.fetchRoutines(userId: userId)
        return routines.sorted{ $0.startTime < $1.startTime }
    }
    
}
