import Foundation
import FirebaseAuth

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
    
    // MARK: - Data Loading
    
    func loadCachedData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        currentUser = CoreDataManager.shared.fetchUser(byId: userId)
        let fetchedRoutines = CoreDataManager.shared.fetchRoutines(forUserId: userId)
        routines = fetchedRoutines.sorted { $0.startTime < $1.startTime }
    }
    
    func syncWithFirebase() async {
        await performSync()
    }
    
    func syncWithFirebaseAndWait() async {
        await performSync()
    }
    
    private func performSync() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            async let firebaseUser = userRepository.fetchUser(userId)
            async let firebaseRoutines = routineRepository.fetchRoutines(userId: userId)
            
            let (fetchedUser, fetchedRoutines) = try await (firebaseUser, firebaseRoutines)
            
            if let fetchedUser = fetchedUser {
                currentUser = fetchedUser
                CoreDataManager.shared.saveUser(fetchedUser)
            }
            
            if !fetchedRoutines.isEmpty {
                routines = fetchedRoutines.sorted { $0.startTime < $1.startTime }
                CoreDataManager.shared.saveRoutines(fetchedRoutines, forUserId: userId)
            }
        } catch {
            print("⚠️ Failed to sync with Firebase: \(error)")
        }
    }
    
    // MARK: - Data Updates
    
    func updateUser(_ user: User) {
        currentUser = user
        CoreDataManager.shared.saveUser(user)
        
        Task {
            try? await userRepository.saveUser(user)
        }
    }
    
    func updateRoutines(_ newRoutines: [RoutineBlock]) {
        routines = newRoutines
        guard let userId = currentUser?.credentials.id else { return }
        CoreDataManager.shared.saveRoutines(newRoutines, forUserId: userId)
        
        Task {
            try? await routineRepository.saveRoutine(newRoutines, userId: userId)
        }
    }
    
    func deleteRoutine(_ routine: RoutineBlock) {
        routines?.removeAll { $0.id == routine.id }
        guard let userId = currentUser?.credentials.id else { return }
        CoreDataManager.shared.deleteRoutine(byId: routine.id)
        
        Task {
            try? await routineRepository.deleteRoutine(routine, userId: userId)
        }
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
            CoreDataManager.shared.saveUser(user)
            Task {
                try? await userRepository.saveUser(user)
            }
        }
        
        if let routines = routines, let userId = user?.credentials.id {
            CoreDataManager.shared.saveRoutines(routines, forUserId: userId)
            Task {
                try? await routineRepository.saveRoutine(routines, userId: userId)
            }
        }
    }
    
    func clearSession() {
        currentUser = nil
        routines = nil
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
    
    var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
