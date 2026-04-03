import Foundation
import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Forma")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data load error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
    
    // MARK: - User Operations
    
    func saveUser(_ user: User) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.credentials.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            let userEntity: UserEntity
            
            if let existingUser = results.first {
                userEntity = existingUser
            } else {
                userEntity = UserEntity(context: context)
                userEntity.id = user.credentials.id
            }
            
            userEntity.name = user.credentials.name
            userEntity.email = user.credentials.email
            userEntity.isAnonymous = user.credentials.isAnonymous
            
            if let preferences = user.preferences {
                userEntity.preferencesData = try? JSONEncoder().encode(preferences)
            }
            
            saveContext()
        } catch {
            print("Error saving user: \(error)")
        }
    }
    
    func fetchUser(byId id: String) -> User? {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let userEntity = results.first {
                return mapUserEntityToUser(userEntity)
            }
        } catch {
            print("Error fetching user: \(error)")
        }
        return nil
    }
    
    func deleteUser(byId id: String) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            for user in results {
                context.delete(user)
            }
            saveContext()
        } catch {
            print("Error deleting user: \(error)")
        }
    }
    
    // MARK: - Routine Operations
    
    func saveRoutine(_ routine: RoutineBlock, forUserId userId: String) {
        let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        
        do {
            let userResults = try context.fetch(userFetchRequest)
            let userEntity: UserEntity
            
            if let existingUser = userResults.first {
                userEntity = existingUser
            } else {
                userEntity = UserEntity(context: context)
                userEntity.id = userId
                userEntity.name = "User"
            }
            
            let routineFetchRequest: NSFetchRequest<RoutineBlockEntity> = RoutineBlockEntity.fetchRequest()
            routineFetchRequest.predicate = NSPredicate(format: "id == %@", routine.id)
            
            let routineResults = try context.fetch(routineFetchRequest)
            let routineEntity: RoutineBlockEntity
            
            if let existingRoutine = routineResults.first {
                routineEntity = existingRoutine
            } else {
                routineEntity = RoutineBlockEntity(context: context)
                routineEntity.id = routine.id
            }
            
            routineEntity.title = routine.title
            routineEntity.blockDescription = routine.description
            routineEntity.startTime = routine.startTime
            routineEntity.endTime = routine.endTime
            routineEntity.icon = routine.icon
            routineEntity.accentColor = routine.accentColor
            routineEntity.intensity = routine.intensity?.rawValue
            routineEntity.user = userEntity
            
            if let existingTasks = routineEntity.tasks as? Set<RoutineTaskEntity> {
                for task in existingTasks {
                    context.delete(task)
                }
            }
            
            for task in routine.tasks {
                let taskEntity = RoutineTaskEntity(context: context)
                taskEntity.id = task.id
                taskEntity.title = task.title
                taskEntity.startTime = task.startTime
                taskEntity.duration = Int32(task.duration)
                taskEntity.blockDescription = task.description
                taskEntity.state = task.state.rawValue
                taskEntity.isBreak = task.isBreak
                taskEntity.routineBlock = routineEntity
            }
            
            saveContext()
        } catch {
            print("Error saving routine: \(error)")
        }
    }
    
    func saveRoutines(_ routines: [RoutineBlock], forUserId userId: String) {
        for routine in routines {
            saveRoutine(routine, forUserId: userId)
        }
    }
    
    func fetchRoutines(forUserId userId: String) -> [RoutineBlock] {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let userEntity = results.first,
               let routineEntities = userEntity.routines as? Set<RoutineBlockEntity> {
                return routineEntities.compactMap { mapRoutineEntityToRoutine($0) }
            }
        } catch {
            print("Error fetching routines: \(error)")
        }
        return []
    }
    
    func deleteRoutine(byId id: String) {
        let fetchRequest: NSFetchRequest<RoutineBlockEntity> = RoutineBlockEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            for routine in results {
                context.delete(routine)
            }
            saveContext()
        } catch {
            print("Error deleting routine: \(error)")
        }
    }
    
    func deleteAllRoutines(forUserId userId: String) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let userEntity = results.first,
               let routines = userEntity.routines as? Set<RoutineBlockEntity> {
                for routine in routines {
                    context.delete(routine)
                }
            }
            saveContext()
        } catch {
            print("Error deleting routines: \(error)")
        }
    }
    
    // MARK: - Mapping Helpers
    
    private func mapUserEntityToUser(_ entity: UserEntity) -> User? {
        guard let id = entity.id,
              let name = entity.name,
              let email = entity.email else { return nil }
        
        let credentials = UserCredentials(
            id: id,
            name: name,
            email: email,
            isAnonymous: entity.isAnonymous
        )
        
        var preferences: UserPreferences?
        if let preferencesData = entity.preferencesData {
            preferences = try? JSONDecoder().decode(UserPreferences.self, from: preferencesData)
        }
        
        return User(credentials: credentials, preferences: preferences)
    }
    
    private func mapRoutineEntityToRoutine(_ entity: RoutineBlockEntity) -> RoutineBlock? {
        guard let id = entity.id,
              let title = entity.title,
              let startTime = entity.startTime,
              let endTime = entity.endTime,
              let icon = entity.icon,
              let accentColor = entity.accentColor else { return nil }
        
        var tasks: [RoutineTask] = []
        if let taskEntities = entity.tasks as? Set<RoutineTaskEntity> {
            tasks = taskEntities.compactMap { mapTaskEntityToTask($0) }
        }
        
        let intensity: BlockIntensity?
        if let intensityRaw = entity.intensity {
            intensity = BlockIntensity(rawValue: intensityRaw)
        } else {
            intensity = nil
        }
        
        return RoutineBlock(
            id: id,
            title: title,
            description: entity.blockDescription,
            startTime: startTime,
            endTime: endTime,
            icon: icon,
            accentColor: accentColor,
            tasks: tasks,
            intensity: intensity
        )
    }
    
    private func mapTaskEntityToTask(_ entity: RoutineTaskEntity) -> RoutineTask? {
        guard let id = entity.id,
              let title = entity.title,
              let startTime = entity.startTime else { return nil }
        
        let state = TaskState(rawValue: entity.state ?? "upcoming") ?? .upcoming
        
        return RoutineTask(
            id: id,
            title: title,
            startTime: startTime,
            duration: Int(entity.duration),
            description: entity.blockDescription,
            state: state,
            isBreak: entity.isBreak
        )
    }
}
