import Foundation

extension Date {
    var dayIndex: Int {
        var cal = Calendar.current
        cal.timeZone = .current
        let comps = cal.dateComponents([.year, .month, .day], from: self)
        guard let y = comps.year, let m = comps.month, let d = comps.day else { return 0 }
        return y * 10000 + m * 100 + d
    }
}
