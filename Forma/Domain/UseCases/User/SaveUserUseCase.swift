//
//  SaveUserUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol SaveUserUseCaseProtocol {
    func execute(_ user: User) async throws
}

final class SaveUserUseCase: SaveUserUseCaseProtocol {
    
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ user: User) async throws {
        try await repository.saveUser(user)
    }
}
