import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        let modelName = "MinimalHabit"
        container = NSPersistentContainer(name: modelName)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Unresolved Core Data error: \(error)") }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func newBackgroundContext() -> NSManagedObjectContext { container.newBackgroundContext() }
}

