import SwiftUI

extension Color {
    init(hex: String) {
        let r, g, b, a: Double
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        if s.count == 6 { s.append("FF") }
        if let val = UInt64(s, radix: 16), s.count == 8 {
            r = Double((val & 0xFF000000) >> 24) / 255.0
            g = Double((val & 0x00FF0000) >> 16) / 255.0
            b = Double((val & 0x0000FF00) >> 8) / 255.0
            a = Double(val & 0x000000FF) / 255.0
            self = Color(red: r, green: g, blue: b, opacity: a)
        } else {
            self = .accentColor
        }
    }
}
