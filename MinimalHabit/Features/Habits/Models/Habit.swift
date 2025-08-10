import Foundation

struct Habit: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String
    var colorHex: String
    var reminderMinutes: Int?
    var isArchived: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct HabitLog: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var habitID: UUID
    var dayIndex: Int
    var isDone: Bool = true
    var timestamp: Date = Date()
}

