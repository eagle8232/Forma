//
//  FetchUserUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol FetchUserUseCaseProtocol {
    func execute(_ userId: String) async throws -> User?
}

final class FetchUserUseCase: FetchUserUseCaseProtocol {
    
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ userId: String) async throws -> User? {
        if let cachedUser = DependencyContainer.shared.currentUser {
            return cachedUser
        }
        
        if let coreDataUser = CoreDataManager.shared.fetchUser(byId: userId) {
            DependencyContainer.shared.currentUser = coreDataUser
            return coreDataUser
        }
        
        let user = try await repository.fetchUser(userId)
        if let user = user {
            DependencyContainer.shared.currentUser = user
        }
        return user
    }
}
