import Foundation

final class AppCoordinator {
    static let shared = AppCoordinator()
    let repository: HabitRepository

    private init() {
        // Core Data backed repository
        self.repository = CoreDataHabitRepository()
    }
}
