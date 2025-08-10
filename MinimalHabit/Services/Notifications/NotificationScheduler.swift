import Foundation

struct NotificationScheduler {
    func requestPermissionIfNeeded() {}
    func scheduleDailyReminder(for habit: Habit) {}
    func cancelReminder(for habitID: UUID) {}
    func rescheduleAll(from habits: [Habit]) {}
}

