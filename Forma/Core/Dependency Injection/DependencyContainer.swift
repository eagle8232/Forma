import Foundation

final class DependencyContainer {
    
    static let shared = DependencyContainer()
    
    private lazy var authRepository: AuthRepositoryProtocol = AuthRepository()
    private lazy var userRepository: UserRepositoryProtocol = UserRepository()
    private lazy var routineRepository: RoutineRepositoryProtocol = RoutineRepository()
    private lazy var aiRepository: AIRepositoryProtocol = AIRepository()
    
    var currentUser: User?
    var routines: [RoutineBlock]?
    
    private var dependencyList: [String: Any] = [:]
    
    private init() {}
    
    func register<T>(_ dependency: T) {
        let key = String(describing: T.self)
        dependencyList[key] = dependency
    }
    
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let dependency = dependencyList[key] as? T else {
            preconditionFailure("No dependency found for \(key)")
        }
        return dependency
    }
}

extension DependencyContainer {
    func makeSignUpAuthUseCase() -> SignUpAuthUseCaseProtocol {
        SignUpAuthUseCase(authRepository: authRepository, userRepository: userRepository, routineRepository: routineRepository)
    }
    
    func makeSignInAuthUseCase() -> SignInAuthUseCaseProtocol {
        SignInAuthUseCase(repository: authRepository)
    }
    
    func makeSignOutAuthUseCase() -> SignOutAuthUseCaseProtocol {
        SignOutAuthUseCase(repository: authRepository)
    }
}

extension DependencyContainer {
    func makeFetchUserUseCase() -> FetchUserUseCaseProtocol {
        FetchUserUseCase(repository: userRepository)
    }
    
    func makeSaveUserUseCase() -> SaveUserUseCaseProtocol {
        SaveUserUseCase(repository: userRepository)
    }
    
    func makeDeleteUserUseCase() -> DeleteUserUseCaseProtocol {
        DeleteUserUseCase(repository: userRepository)
    }
}

extension DependencyContainer {
    func makeFetchRoutinesUseCase() -> FetchRoutinesUseCaseProtocol {
        FetchRoutinesUseCase(repository: routineRepository)
    }
    
    func makeSaveRoutineUseCase() -> SaveRoutineUseCaseProtocol {
        SaveRoutineUseCase(repository: routineRepository)
    }
    
    func makeDeleteRoutineUseCase() -> DeleteRoutineUseCaseProtocol {
        DeleteRoutineUseCase(repository: routineRepository)
    }
}

extension DependencyContainer {
    func makeGenerateRoutineUseCase() -> GenerateRoutineUseCaseProtocol {
        GenerateRoutineUseCase(aiRepository: aiRepository)
    }
}

extension DependencyContainer {
    func saveData(routines: [RoutineBlock]? = nil, user: User? = nil) {
        self.routines = routines
        self.currentUser = user
        
        if let user = user {
            saveUserToDefaults(user)
        }
        if let routines = routines {
            saveRoutinesToDefaults(routines)
        }
    }
    
    func clearSession() {
        currentUser = nil
        routines = nil
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "savedRoutines")
    }
    
    private func saveUserToDefaults(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "savedUser")
        }
    }
    
    private func saveRoutinesToDefaults(_ routines: [RoutineBlock]) {
        if let encoded = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(encoded, forKey: "savedRoutines")
        }
    }
    
    func loadSavedData() {
        if let data = UserDefaults.standard.data(forKey: "savedRoutines"),
           let routines = try? JSONDecoder().decode([RoutineBlock].self, from: data) {
            self.routines = routines
        }
        if let data = UserDefaults.standard.data(forKey: "savedUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
        }
    }
    
    var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
