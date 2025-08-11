import SwiftUI

struct StreakCalendarView: View {
    let days: [Int]
    let done: Set<Int>
    var onTap: (Int) -> Void

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(days, id: \.self) { idx in
                let filled = done.contains(idx)
                Text(dayNumber(idx))
                    .frame(height: 34)
                    .frame(maxWidth: .infinity)
                    .background(filled ? Color.accentColor.opacity(0.2) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .onTapGesture { onTap(idx) }
            }
        }
    }

    private func dayNumber(_ idx: Int) -> String {
        return String(idx % 100)
    }
}

