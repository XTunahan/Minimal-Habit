import Foundation

protocol HabitRepository {
    func fetchHabits(includeArchived: Bool) -> [Habit]
    func habit(by id: UUID) -> Habit?
    func save(habit: Habit) throws
    func delete(habitID: UUID) throws
    @discardableResult
    func toggle(habitID: UUID, on dayIndex: Int) throws -> Habit
    func logs(habitID: UUID, in range: ClosedRange<Int>) -> [HabitLog]
}

// Temporary in-memory implementation to keep the app runnable during scaffolding.
final class InMemoryHabitRepository: HabitRepository {
    private var habits: [UUID: Habit] = [:]
    private var logsStore: [UUID: [Int: HabitLog]] = [:]

    func fetchHabits(includeArchived: Bool) -> [Habit] {
        habits.values.filter { includeArchived || !$0.isArchived }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func habit(by id: UUID) -> Habit? { habits[id] }

    func save(habit: Habit) throws { habits[habit.id] = habit }

    func delete(habitID: UUID) throws {
        habits.removeValue(forKey: habitID)
        logsStore.removeValue(forKey: habitID)
    }

    @discardableResult
    func toggle(habitID: UUID, on dayIndex: Int) throws -> Habit {
        guard var habit = habits[habitID] else { throw NSError(domain: "HabitNotFound", code: 1) }
        var logs = logsStore[habitID] ?? [:]
        if let existing = logs[dayIndex] {
            // toggle off
            if existing.isDone { logs.removeValue(forKey: dayIndex) }
        } else {
            logs[dayIndex] = HabitLog(habitID: habitID, dayIndex: dayIndex, isDone: true, timestamp: Date())
        }
        logsStore[habitID] = logs
        habit.updatedAt = Date()
        habits[habitID] = habit
        return habit
    }

    func logs(habitID: UUID, in range: ClosedRange<Int>) -> [HabitLog] {
        let dict = logsStore[habitID] ?? [:]
        return dict.values.filter { range.contains($0.dayIndex) }
    }
}

