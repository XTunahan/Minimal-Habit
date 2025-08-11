import Foundation

@MainActor
final class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []

    private let repo: HabitRepository = AppCoordinator.shared.repository

    func load() {
        habits = repo.fetchHabits(includeArchived: false)
    }

    func toggleToday(_ habit: Habit) {
        guard let today = dayIndex(Date()) else { return }
        _ = try? repo.toggle(habitID: habit.id, on: today)
        load()
    }

    func delete(_ habit: Habit) {
        try? repo.delete(habitID: habit.id)
        load()
    }
}

