import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    var onToggle: () -> Void

    var body: some View {
        HStack {
            Circle().fill(Color(hex: habit.colorHex)).frame(width: 12, height: 12)
            Text(habit.name)
            Spacer()
            Button(action: onToggle) {
                Image(systemName: "checkmark.circle")
            }
            .buttonStyle(.plain)
        }
    }
}

