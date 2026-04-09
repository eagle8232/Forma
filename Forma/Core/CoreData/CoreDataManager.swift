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
        context.perform { [weak self] in
            guard let self = self else { return }
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    print("Core Data save error: \(error)")
                }
            }
        }
    }
    
    // MARK: - User Operations
    
    func saveUser(_ user: User) {
        guard !user.credentials.id.isEmpty else { return }
        
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", user.credentials.id)
            
            do {
                let results = try self.context.fetch(fetchRequest)
                let userEntity: UserEntity
                
                if let existingUser = results.first {
                    userEntity = existingUser
                } else {
                    userEntity = UserEntity(context: self.context)
                    userEntity.id = user.credentials.id
                }
                
                userEntity.name = user.credentials.name
                userEntity.email = user.credentials.email
                userEntity.isAnonymous = user.credentials.isAnonymous
                
                if let preferences = user.preferences {
                    userEntity.preferencesData = try? JSONEncoder().encode(preferences)
                }
                
                self.saveContext()
            } catch {
                print("Error saving user: \(error)")
            }
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
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let results = try self.context.fetch(fetchRequest)
                for user in results {
                    self.context.delete(user)
                }
                self.saveContext()
            } catch {
                print("Error deleting user: \(error)")
            }
        }
    }
    
    // MARK: - Routine Operations
    
    func saveRoutine(_ routine: RoutineBlock, forUserId userId: String) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "id == %@", userId)
            
            do {
                let userResults = try self.context.fetch(userFetchRequest)
                let userEntity: UserEntity
                
                if let existingUser = userResults.first {
                    userEntity = existingUser
                } else {
                    userEntity = UserEntity(context: self.context)
                    userEntity.id = userId
                    userEntity.name = "User"
                }
                
                guard userEntity.id != nil, userId.isEmpty == false else { return }
                
                let routineFetchRequest: NSFetchRequest<RoutineBlockEntity> = RoutineBlockEntity.fetchRequest()
                routineFetchRequest.predicate = NSPredicate(format: "id == %@", routine.id)
                
                let routineResults = try self.context.fetch(routineFetchRequest)
                let routineEntity: RoutineBlockEntity
                
                if let existingRoutine = routineResults.first {
                    routineEntity = existingRoutine
                } else {
                    routineEntity = RoutineBlockEntity(context: self.context)
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
                        self.context.delete(task)
                    }
                }
                
                for task in routine.tasks {
                    let taskEntity = RoutineTaskEntity(context: self.context)
                    taskEntity.id = task.id
                    taskEntity.title = task.title
                    taskEntity.startTime = task.startTime
                    taskEntity.duration = Int32(task.duration)
                    taskEntity.blockDescription = task.description
                    taskEntity.state = task.state.rawValue
                    taskEntity.isBreak = task.isBreak
                    taskEntity.routineBlock = routineEntity
                }
                
                self.saveContext()
            } catch {
                print("Error saving routine: \(error)")
            }
        }
    }
    
    func saveRoutines(_ routines: [RoutineBlock], forUserId userId: String) {
        for routine in routines {
            saveRoutine(routine, forUserId: userId)
        }
    }
    
    func fetchRoutines(forUserId userId: String) -> [RoutineBlock] {
        var result: [RoutineBlock] = []
        
        context.performAndWait {
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
            
            do {
                let results = try context.fetch(fetchRequest)
                if let userEntity = results.first,
                   let routineEntities = userEntity.routines as? Set<RoutineBlockEntity> {
                    result = routineEntities.compactMap { mapRoutineEntityToRoutine($0) }
                }
            } catch {
                print("Error fetching routines: \(error)")
            }
        }
        
        print("[DEBUG CoreData] fetchRoutines returned \(result.count) routines")
        return result
    }
    
    func deleteRoutine(byId id: String) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<RoutineBlockEntity> = RoutineBlockEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let results = try self.context.fetch(fetchRequest)
                for routine in results {
                    self.context.delete(routine)
                }
                self.saveContext()
            } catch {
                print("Error deleting routine: \(error)")
            }
        }
    }
    
    func deleteAllRoutines(forUserId userId: String) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
            
            do {
                let results = try self.context.fetch(fetchRequest)
                if let userEntity = results.first,
                   let routines = userEntity.routines as? Set<RoutineBlockEntity> {
                    for routine in routines {
                        self.context.delete(routine)
                    }
                }
                self.saveContext()
            } catch {
                print("Error deleting routines: \(error)")
            }
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
    
    // MARK: - Completion Records
    
    func saveCompletionRecord(routineId: String, completedTasks: [String: Bool], userId: String) {
        guard !userId.isEmpty else { return }
        
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "id == %@", userId)
            
            do {
                let userResults = try self.context.fetch(userFetchRequest)
                let userEntity: UserEntity
                
                if let existingUser = userResults.first {
                    userEntity = existingUser
                } else {
                    userEntity = UserEntity(context: self.context)
                    userEntity.id = userId
                    userEntity.name = "User"
                }
                
                guard userEntity.id != nil else { return }
                
                let recordEntity = CompletionRecordEntity(context: self.context)
                recordEntity.id = UUID().uuidString
                recordEntity.routineId = routineId
                recordEntity.date = Date()
                recordEntity.totalTasks = Int16(completedTasks.count)
                recordEntity.completedTasks = Int16(completedTasks.values.filter { $0 }.count)
                recordEntity.completionData = try? JSONEncoder().encode(completedTasks)
                recordEntity.user = userEntity
                
                self.saveContext()
            } catch {
                print("Error saving completion record: \(error)")
            }
        }
    }
    
    func fetchCompletionRecords(forUserId userId: String, from startDate: Date? = nil, to endDate: Date? = nil) -> [CompletionRecord] {
        guard !userId.isEmpty else { return [] }
        
        let fetchRequest: NSFetchRequest<CompletionRecordEntity> = CompletionRecordEntity.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        predicates.append(NSPredicate(format: "user.id == %@", userId))
        
        if let startDate = startDate {
            predicates.append(NSPredicate(format: "date >= %@", startDate as NSDate))
        }
        
        if let endDate = endDate {
            predicates.append(NSPredicate(format: "date <= %@", endDate as NSDate))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { mapCompletionEntityToRecord($0) }
        } catch {
            print("Error fetching completion records: \(error)")
            return []
        }
    }
    
    func fetchTodayCompletionRecord(forUserId userId: String, routineId: String) -> CompletionRecord? {
        guard !userId.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<CompletionRecordEntity> = CompletionRecordEntity.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "user.id == %@", userId),
            NSPredicate(format: "routineId == %@", routineId),
            NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        ])
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first.flatMap { mapCompletionEntityToRecord($0) }
        } catch {
            print("Error fetching today's completion record: \(error)")
            return nil
        }
    }
    
    func fetchStreak(forUserId userId: String) -> Int {
        guard !userId.isEmpty else { return 0 }
        
        let records = fetchCompletionRecords(forUserId: userId)
        guard !records.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let completedDates = Set(records.map { calendar.startOfDay(for: $0.date) })
        
        var streak = 0
        var currentDate: Date
        
        if completedDates.contains(today) {
            currentDate = today
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  completedDates.contains(yesterday) {
            currentDate = yesterday
        } else {
            return 0
        }
        
        while completedDates.contains(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    private func mapCompletionEntityToRecord(_ entity: CompletionRecordEntity) -> CompletionRecord? {
        guard let id = entity.id,
              let routineId = entity.routineId,
              let date = entity.date else { return nil }
        
        var completedTasks: [String: Bool] = [:]
        if let data = entity.completionData {
            completedTasks = (try? JSONDecoder().decode([String: Bool].self, from: data)) ?? [:]
        }
        
        return CompletionRecord(
            id: id,
            routineId: routineId,
            date: date,
            completedTasks: completedTasks,
            totalTasks: Int(entity.totalTasks),
            completedCount: Int(entity.completedTasks)
        )
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let entityNames = ["UserEntity", "RoutineBlockEntity", "RoutineTaskEntity", "CompletionRecordEntity"]
            
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try self.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: self.context)
                } catch {
                    print("Error clearing \(entityName): \(error)")
                }
            }
            
            self.saveContext()
        }
    }
}
