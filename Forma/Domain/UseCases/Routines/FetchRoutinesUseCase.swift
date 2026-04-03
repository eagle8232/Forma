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
        if let cachedRoutines = DependencyContainer.shared.routines, !cachedRoutines.isEmpty {
            return cachedRoutines.sorted { $0.startTime < $1.startTime }
        }
        
        let routines = try await repository.fetchRoutines(userId: userId)
        
        if routines.isEmpty {
            let coreDataRoutines = CoreDataManager.shared.fetchRoutines(forUserId: userId)
            if !coreDataRoutines.isEmpty {
                DependencyContainer.shared.routines = coreDataRoutines
                return coreDataRoutines.sorted { $0.startTime < $1.startTime }
            }
        }
        
        return routines.sorted { $0.startTime < $1.startTime }
    }
    
}
