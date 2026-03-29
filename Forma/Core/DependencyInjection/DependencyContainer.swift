//
//  DependencyContainer.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/9/26.
//

import Foundation

class DependencyContainer {
    
    static let shared = DependencyContainer()
    
    private lazy var authRepository: AuthRepositoryProtocol = AuthRepository()
    private lazy var userRepository: UserRepositoryProtocol = UserRepository()
    private lazy var routineRepository: RoutineRepositoryProtocol = RoutineRepository()
    private lazy var aiRepository: AIRepositoryProtocol = AIRepository()
    
    // Variables
    var currentUser: User?
    var routines:    [RoutineBlock]?
    
    private init() {}
   
}

// MARK: - Auth Module

extension DependencyContainer {
    
    // - Sign Up Auth Use Case
    func makeSignUpAuthUseCase() -> SignUpAuthUseCaseProtocol{
        return SignUpAuthUseCase(
            authRepository: authRepository,
            userRepository: userRepository,
            routineRepository: routineRepository)
    }
    
    // - Sign In Auth Use Case
    func makeSignInAuthUseCase() -> SignInAuthUseCaseProtocol{
        return SignInAuthUseCase(repository: authRepository)
    }
    
    // - Sign Out Auth Use Case
    func makeSignOutAuthUseCase() -> SignOutAuthUseCaseProtocol {
        return SignOutAuthUseCase(repository: authRepository)
    }
}

// MARK: - User Module

extension DependencyContainer {
    
    // - Fetch User Use Case
    func makeFetchUserUseCase() -> FetchUserUseCaseProtocol {
        return FetchUserUseCase(repository: userRepository)
    }
    
    // - Save User Use Case
    func makeSaveUserUseCase() -> SaveUserUseCaseProtocol {
        return SaveUserUseCase(repository: userRepository)
    }
    
    // - Delete User Use Case
    func makeDeleteUserUseCase() -> DeleteUserUseCaseProtocol {
        return DeleteUserUseCase(repository: userRepository)
    }
}

// MARK: - Routine Module

extension DependencyContainer {
    
    // - Fetch User Use Case
    func makeFetchRoutinesUseCase() -> FetchRoutinesUseCaseProtocol {
        return FetchRoutinesUseCase(repository: routineRepository)
    }
    
    // - Save User Use Case
    func makeSaveRoutineUseCase() -> SaveRoutineUseCaseProtocol {
        return SaveRoutineUseCase(repository: routineRepository)
    }
    
    // - Delete User Use Case
    func makeDeleteRoutineUseCase() -> DeleteRoutineUseCaseProtocol {
        return DeleteRoutineUseCase(repository: routineRepository)
    }
}

// MARK: - AI Module

extension DependencyContainer {
    // - Generate Routine Use Case
    func makeGenerateRoutineUseCase() -> GenerateRoutineUseCaseProtocol {
        return GenerateRoutineUseCase(aiRepository: aiRepository)
    }
}

// MARK: - Session

extension DependencyContainer {
    
    func saveData(routines: [RoutineBlock]? = nil, user: User? = nil) {
        self.routines = routines
        self.currentUser = user
    }
    // - Clears Session On Sign Out or Delete
    func clearSession() {
        self.currentUser = nil
        self.routines    = nil
    }
}
