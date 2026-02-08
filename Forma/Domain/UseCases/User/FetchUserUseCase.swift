//
//  FetchUserUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol FetchUserUseCaseProtocol {
    func execute() async throws -> User
}

final class FetchUserUseCase: FetchUserUseCaseProtocol {
    
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> User {
        let user = try await repository.fetchUser()
        return user
    }
}
