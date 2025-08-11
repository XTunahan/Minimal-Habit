import Foundation
import UserNotifications

struct NotificationScheduler {
    func requestPermissionIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleDailyReminder(for habit: Habit) {
        guard let minutes = habit.reminderMinutes else { return }
        let content = UNMutableNotificationContent()
        content.title = habit.name
        content.body = "Erinnerung: Heute abhaken"
        content.sound = .default

        let hour = minutes / 60
        let minute = minutes % 60
        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let id = notificationID(for: habit.id)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func cancelReminder(for habitID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID(for: habitID)])
    }

    func rescheduleAll(from habits: [Habit]) {
        let ids = habits.map { notificationID(for: $0.id) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        habits.forEach { scheduleDailyReminder(for: $0) }
    }
}

private func notificationID(for habitID: UUID) -> String { "habit.reminder." + habitID.uuidString }
