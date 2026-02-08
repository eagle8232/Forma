//
//  FetchActivitiesUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol FetchActivitiesUseCaseProtocol {
    func execute(with id: String) async throws -> [Activity]
}

final class FetchActivitiesUseCase: FetchActivitiesUseCaseProtocol {
    
    private let repository: ActivityRepositoryProtocol
    
    init(repository: ActivityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(with id: String) async throws -> [Activity] {
        let activities = try await repository.fetchActivities(with: id)
        return activities.sorted{$0.startTime < $1.startTime}
    }
}
