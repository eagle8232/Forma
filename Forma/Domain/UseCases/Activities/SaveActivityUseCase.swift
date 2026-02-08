//
//  SaveActivityUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol SaveActivityUseCaseProtocol {
    func execute(_ activity: Activity) async throws
}

final class SaveActivityUseCase: SaveActivityUseCaseProtocol {
    
    private let repository: ActivityRepositoryProtocol
    
    init(repository: ActivityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ activity: Activity) async throws {
        try await repository.saveActivity(activity)
    }
}
