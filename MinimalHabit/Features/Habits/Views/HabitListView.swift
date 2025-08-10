import SwiftUI

struct HabitListView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Minimal Habit")
                    .font(.title2)
                Text("Erstelle dein erstes Habit")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Habits")
        }
    }
}

#Preview {
    HabitListView()
}

