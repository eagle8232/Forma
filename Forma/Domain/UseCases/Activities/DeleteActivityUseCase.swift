//
//  DeleteActivityUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol DeleteActivityUseCaseProtocol {
    func execute(_ activity: Activity) async throws
}

final class DeleteActivityUseCase: DeleteActivityUseCaseProtocol {
    
    private let repository: ActivityRepositoryProtocol
    
    init(repository: ActivityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ activity: Activity) async throws {
        try await repository.deleteActivity(activity)
    }
}
