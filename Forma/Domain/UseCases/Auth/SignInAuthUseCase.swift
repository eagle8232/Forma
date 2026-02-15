//
//  AuthSignInUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol SignInAuthUseCaseProtocol {
    func execute(with authProvider: AuthProvider) async throws -> UserCredentials?
}

class SignInAuthUseCase: SignInAuthUseCaseProtocol {
    
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(with authProvider: AuthProvider) async throws -> UserCredentials? {
        let user = try await repository.signIn(with: authProvider)
        return user
    }
}
