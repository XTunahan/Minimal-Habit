import Foundation

enum DateGrid {
    static func currentMonthDayIndices(calendar: Calendar = .current) -> [Int] {
        let now = Date()
        var cal = calendar
        cal.timeZone = .current
        let comps = cal.dateComponents([.year, .month], from: now)
        guard let firstOfMonth = cal.date(from: comps) else { return [] }
        let range = cal.range(of: .day, in: .month, for: firstOfMonth) ?? 1...28
        return range.compactMap { day -> Int? in
            var c = comps
            c.day = day
            guard let date = cal.date(from: c) else { return nil }
            return dayIndex(date)
        }
    }
}

