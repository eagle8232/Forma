//
//  DeleteUserUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol DeleteUserUseCaseProtocol {
    func execute(_ user: User) async throws
}

final class DeleteUserUseCase: DeleteUserUseCaseProtocol {
    
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ user: User) async throws {
        try await repository.deleteUser(user)
    }
}
