//
//  UpdateUserUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol UpdateUserUseCaseProtocol {
    func exeecute(_ user: User) async throws
}

final class UpdateUserUseCase: UpdateUserUseCaseProtocol {
    
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func exeecute(_ user: User) async throws {
        try await repository.updateUser(user)
    }
}
