//
//  SignUpAuthUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol SignUpAuthUseCaseProtocol {
    func execute(with authProvider: AuthProvider) async throws -> UserCredentials?
}

class SignUpAuthUseCase: SignUpAuthUseCaseProtocol {
    
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(with authProvider: AuthProvider) async throws -> UserCredentials? {
        let user = try await repository.signUp(with: authProvider)
        return user
    }
}
