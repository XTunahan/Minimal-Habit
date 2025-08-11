import Foundation

@MainActor
final class HabitDetailViewModel: ObservableObject {
    @Published var habit: Habit
    @Published var monthDays: [Int] = [] // dayIndex list for current month
    @Published var doneDays: Set<Int> = []

    private let repo: HabitRepository = AppCoordinator.shared.repository

    init(habit: Habit) {
        self.habit = habit
        self.monthDays = DateGrid.currentMonthDayIndices()
        reloadLogs()
    }

    func reloadLogs() {
        guard let first = monthDays.first, let last = monthDays.last else { return }
        let logs = repo.logs(habitID: habit.id, in: first...last)
        doneDays = Set(logs.filter { $0.isDone }.map { $0.dayIndex })
    }

    func toggle(dayIndex: Int) {
        _ = try? repo.toggle(habitID: habit.id, on: dayIndex)
        reloadLogs()
    }
}

