//
//  SignOutAuthUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol SignOutAuthUseCaseProtocol {
    func execute() async throws
}

class SignOutAuthUseCase: SignOutAuthUseCaseProtocol {
    
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws {
        try repository.signOut()
    }
}
