import Foundation

final class AppCoordinator {
    static let shared = AppCoordinator()
    let repository: HabitRepository

    private init() {
        // Swap with Core Data backed repo later
        self.repository = InMemoryHabitRepository()
    }
}

