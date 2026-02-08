//
//  UpdateActivityUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol UpdateActivityUseCaseProtocol {
    func execute(_ activity: Activity) async throws
}

final class UpdateActivityUseCase: UpdateActivityUseCaseProtocol {
    
    private let repository: ActivityRepositoryProtocol
    
    init(repository: ActivityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ activity: Activity) async throws {
        try await repository.updateActivity(activity)
    }
}
