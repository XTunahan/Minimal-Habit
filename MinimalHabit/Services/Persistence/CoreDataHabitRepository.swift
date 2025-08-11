import Foundation
import CoreData

enum RepositoryError: Error { case habitNotFound }

final class CoreDataHabitRepository: HabitRepository {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    private var viewContext: NSManagedObjectContext { container.viewContext }

    func fetchHabits(includeArchived: Bool) -> [Habit] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "HabitEntity")
        if !includeArchived {
            request.predicate = NSPredicate(format: "isArchived == NO")
        }
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        do {
            let objs = try viewContext.fetch(request)
            return objs.compactMap { HabitEntityMapper.toModel(from: $0) }
        } catch {
            return []
        }
    }

    func habit(by id: UUID) -> Habit? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "HabitEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        let obj = try? viewContext.fetch(request).first
        return obj.flatMap { HabitEntityMapper.toModel(from: $0) }
    }

    func save(habit: Habit) throws {
        let ctx = container.newBackgroundContext()
        try ctx.performAndWait {
            let request = NSFetchRequest<NSManagedObject>(entityName: "HabitEntity")
            request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
            let obj = try ctx.fetch(request).first ?? NSEntityDescription.insertNewObject(forEntityName: "HabitEntity", into: ctx)
            HabitEntityMapper.apply(habit: habit, to: obj)
            try ctx.save()
        }
    }

    func delete(habitID: UUID) throws {
        let ctx = container.newBackgroundContext()
        try ctx.performAndWait {
            let req = NSFetchRequest<NSManagedObject>(entityName: "HabitEntity")
            req.predicate = NSPredicate(format: "id == %@", habitID as CVarArg)
            if let obj = try ctx.fetch(req).first {
                ctx.delete(obj)
                // delete logs for habit
                let logReq = NSFetchRequest<NSManagedObject>(entityName: "HabitLogEntity")
                logReq.predicate = NSPredicate(format: "habitID == %@", habitID as CVarArg)
                let logs = try ctx.fetch(logReq)
                logs.forEach { ctx.delete($0) }
                try ctx.save()
            }
        }
    }

    @discardableResult
    func toggle(habitID: UUID, on dayIndex: Int) throws -> Habit {
        let ctx = container.newBackgroundContext()
        var updated: Habit?
        try ctx.performAndWait {
            // ensure habit exists
            let habitReq = NSFetchRequest<NSManagedObject>(entityName: "HabitEntity")
            habitReq.predicate = NSPredicate(format: "id == %@", habitID as CVarArg)
            guard let habitObj = try ctx.fetch(habitReq).first else { throw RepositoryError.habitNotFound }

            // find log for (habitID, dayIndex)
            let logReq = NSFetchRequest<NSManagedObject>(entityName: "HabitLogEntity")
            logReq.predicate = NSPredicate(format: "habitID == %@ AND dayIndex == %d", habitID.uuidString, dayIndex)
            logReq.fetchLimit = 1
            if let existing = try ctx.fetch(logReq).first {
                ctx.delete(existing)
            } else {
                let log = NSEntityDescription.insertNewObject(forEntityName: "HabitLogEntity", into: ctx)
                log.setValue(UUID().uuidString, forKey: "id")
                log.setValue(habitID.uuidString, forKey: "habitID")
                log.setValue(Int32(dayIndex), forKey: "dayIndex")
                log.setValue(true, forKey: "isDone")
                log.setValue(Date(), forKey: "timestamp")
            }

            habitObj.setValue(Date(), forKey: "updatedAt")
            try ctx.save()

            updated = HabitEntityMapper.toModel(from: habitObj)
        }
        guard let result = updated else { throw RepositoryError.habitNotFound }
        return result
    }

    func logs(habitID: UUID, in range: ClosedRange<Int>) -> [HabitLog] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "HabitLogEntity")
        req.predicate = NSPredicate(format: "habitID == %@ AND dayIndex >= %d AND dayIndex <= %d", habitID.uuidString, range.lowerBound, range.upperBound)
        do {
            let objs = try viewContext.fetch(req)
            return objs.compactMap { HabitLogEntityMapper.toModel(from: $0) }
        } catch { return [] }
    }
}

private enum HabitEntityMapper {
    static func toModel(from obj: NSManagedObject) -> Habit {
        let idAny = obj.value(forKey: "id")
        let id: UUID = (idAny as? UUID) ?? (idAny as? String).flatMap { UUID(uuidString: $0) } ?? UUID()
        return Habit(
            id: id,
            name: obj.value(forKey: "name") as? String ?? "",
            colorHex: obj.value(forKey: "colorHex") as? String ?? "#5B8DEF",
            reminderMinutes: obj.value(forKey: "reminderMinutes") as? Int,
            isArchived: obj.value(forKey: "isArchived") as? Bool ?? false,
            createdAt: obj.value(forKey: "createdAt") as? Date ?? Date(),
            updatedAt: obj.value(forKey: "updatedAt") as? Date ?? Date()
        )
    }

    static func apply(habit: Habit, to obj: NSManagedObject) {
        obj.setValue(habit.id.uuidString, forKey: "id")
        obj.setValue(habit.name, forKey: "name")
        obj.setValue(habit.colorHex, forKey: "colorHex")
        if let minutes = habit.reminderMinutes { obj.setValue(minutes, forKey: "reminderMinutes") } else { obj.setValue(nil, forKey: "reminderMinutes") }
        obj.setValue(habit.isArchived, forKey: "isArchived")
        obj.setValue(habit.createdAt, forKey: "createdAt")
        obj.setValue(Date(), forKey: "updatedAt")
    }
}

private enum HabitLogEntityMapper {
    static func toModel(from obj: NSManagedObject) -> HabitLog {
        let idAny = obj.value(forKey: "id")
        let id: UUID = (idAny as? UUID) ?? (idAny as? String).flatMap { UUID(uuidString: $0) } ?? UUID()
        let hidAny = obj.value(forKey: "habitID")
        let hid: UUID = (hidAny as? UUID) ?? (hidAny as? String).flatMap { UUID(uuidString: $0) } ?? UUID()
        return HabitLog(
            id: id,
            habitID: hid,
            dayIndex: Int(obj.value(forKey: "dayIndex") as? Int32 ?? 0),
            isDone: obj.value(forKey: "isDone") as? Bool ?? true,
            timestamp: obj.value(forKey: "timestamp") as? Date ?? Date()
        )
    }
}
