//
//  DeleteUserAuthUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol DeleteUserAuthUseCaseProtocol {
    func execute() async throws
}

class DeleteUserAuthUseCase: DeleteUserAuthUseCaseProtocol {
    
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws {
        try repository.deleteUser()
    }
}
