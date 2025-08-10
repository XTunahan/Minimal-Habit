import Foundation

enum StreakCalculator {
    static func currentStreak(days: Set<Int>) -> Int {
        guard let today = dayIndex(Date()) else { return 0 }
        var count = 0
        var idx = today
        while days.contains(idx) {
            count += 1
            idx = previousDayIndex(idx)
        }
        return count
    }

    static func bestStreak(days: Set<Int>) -> Int {
        guard !days.isEmpty else { return 0 }
        let sorted = days.sorted()
        var best = 1
        var run = 1
        for i in 1..<sorted.count {
            if sorted[i] == nextDayIndex(sorted[i-1]) { run += 1; best = max(best, run) }
            else { run = 1 }
        }
        return best
    }

    static func completionRate(days: Set<Int>, since startIndex: Int) -> Double {
        guard let today = dayIndex(Date()) else { return 0 }
        let total = max(1, daysBetween(startIndex, today) + 1)
        let completed = days.filter { $0 >= startIndex && $0 <= today }.count
        return Double(completed) / Double(total)
    }
}

// MARK: - Date helpers

func dayIndex(_ date: Date) -> Int? {
    var cal = Calendar.current
    cal.timeZone = .current
    let comps = cal.dateComponents([.year, .month, .day], from: date)
    guard let y = comps.year, let m = comps.month, let d = comps.day else { return nil }
    return y * 10000 + m * 100 + d
}

func previousDayIndex(_ idx: Int) -> Int {
    let y = idx / 10000
    let m = (idx / 100) % 100
    let d = idx % 100
    var comps = DateComponents(year: y, month: m, day: d)
    let cal = Calendar.current
    let date = cal.date(from: comps) ?? Date()
    let prev = cal.date(byAdding: .day, value: -1, to: date) ?? date
    return dayIndex(prev) ?? idx
}

func nextDayIndex(_ idx: Int) -> Int {
    let y = idx / 10000
    let m = (idx / 100) % 100
    let d = idx % 100
    var comps = DateComponents(year: y, month: m, day: d)
    let cal = Calendar.current
    let date = cal.date(from: comps) ?? Date()
    let next = cal.date(byAdding: .day, value: 1, to: date) ?? date
    return dayIndex(next) ?? idx
}

func daysBetween(_ start: Int, _ end: Int) -> Int {
    let cal = Calendar.current
    func date(from idx: Int) -> Date {
        let y = idx / 10000
        let m = (idx / 100) % 100
        let d = idx % 100
        return cal.date(from: DateComponents(year: y, month: m, day: d)) ?? Date()
    }
    let s = date(from: start)
    let e = date(from: end)
    return cal.dateComponents([.day], from: s, to: e).day ?? 0
}

