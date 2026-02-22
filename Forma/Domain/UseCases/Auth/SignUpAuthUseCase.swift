//
//  SignUpAuthUseCase.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

protocol SignUpAuthUseCaseProtocol {
    func execute(with authProvider: AuthProvider,
                 userPreferences: UserPreferences,
                 routines: [RoutineBlock]) async throws -> User?
}

class SignUpAuthUseCase: SignUpAuthUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let routineRepository: RoutineRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol,
         userRepository: UserRepositoryProtocol,
         routineRepository: RoutineRepositoryProtocol
    ) {
        
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.routineRepository = routineRepository
    }
    
    func execute(
        with authProvider: AuthProvider,
        userPreferences: UserPreferences,
        routines: [RoutineBlock]) async throws -> User?
    {
        guard let userCredentials = try await authRepository.signUp(with: authProvider) else {
            return nil
        }
        
        let user = User(
            credentials: userCredentials,
            preferences: userPreferences
        )
        
        try await userRepository.saveUser(user)
        
        try await routineRepository.saveRoutine(routines, userId: userCredentials.id)

        return nil
    }
}
