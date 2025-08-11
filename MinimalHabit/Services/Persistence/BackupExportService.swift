import Foundation

struct ExportPackage: Codable { let version: Int; let habits: [Habit]; let logs: [HabitLog] }

enum BackupExportError: Error { case invalidData }

struct BackupExportService {
    let repo: HabitRepository = AppCoordinator.shared.repository

    func exportAll() throws -> Data {
        let habits = repo.fetchHabits(includeArchived: true)
        // for now, export last 2 years of logs per habit
        let cal = Calendar.current
        let twoYearsAgo = cal.date(byAdding: .year, value: -2, to: Date()) ?? Date()
        let start = dayIndex(twoYearsAgo) ?? 0
        let end = dayIndex(Date()) ?? start
        var logs: [HabitLog] = []
        for h in habits {
            logs.append(contentsOf: repo.logs(habitID: h.id, in: start...end))
        }
        let pkg = ExportPackage(version: 1, habits: habits, logs: logs)
        return try JSONEncoder().encode(pkg)
    }

    func `import`(data: Data) throws -> ExportPackage {
        let incoming = try JSONDecoder().decode(ExportPackage.self, from: data)
        // Merge by id; newer updatedAt wins for habits; for logs newer timestamp wins
        let existingHabits = repo.fetchHabits(includeArchived: true)
        var byID = Dictionary(uniqueKeysWithValues: existingHabits.map { ($0.id, $0) })
        for h in incoming.habits {
            if let ex = byID[h.id] {
                let winner = (h.updatedAt >= ex.updatedAt) ? h : ex
                try? repo.save(habit: winner)
            } else {
                try? repo.save(habit: h)
            }
        }
        for l in incoming.logs {
            // Toggle to set state idempotently
            let current = repo.logs(habitID: l.habitID, in: l.dayIndex...l.dayIndex).first
            if (current == nil) && l.isDone {
                _ = try? repo.toggle(habitID: l.habitID, on: l.dayIndex)
            } else if (current != nil) && !l.isDone {
                _ = try? repo.toggle(habitID: l.habitID, on: l.dayIndex)
            }
        }
        return incoming
    }
}

