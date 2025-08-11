import Foundation

@MainActor
final class EditHabitViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var colorHex: String = "#5B8DEF"
    @Published var reminderMinutes: Int? = nil
    @Published var isArchived: Bool = false

    private let repo: HabitRepository = AppCoordinator.shared.repository
    private(set) var existingID: UUID? = nil

    init(habit: Habit? = nil) {
        if let h = habit {
            existingID = h.id
            name = h.name
            colorHex = h.colorHex
            reminderMinutes = h.reminderMinutes
            isArchived = h.isArchived
        }
    }

    var canSave: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func save() throws {
        var h = Habit(
            id: existingID ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            colorHex: colorHex,
            reminderMinutes: reminderMinutes,
            isArchived: isArchived,
            createdAt: Date(),
            updatedAt: Date()
        )
        if let id = existingID, let current = repo.habit(by: id) { h.createdAt = current.createdAt }
        try repo.save(habit: h)
    }

    func delete() throws {
        if let id = existingID { try repo.delete(habitID: id) }
    }
}

