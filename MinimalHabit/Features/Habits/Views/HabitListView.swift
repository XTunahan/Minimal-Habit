import SwiftUI

struct HabitListView: View {
    @StateObject private var vm = HabitListViewModel()
    @State private var showingEditor: Bool = false
    @State private var editHabit: Habit? = nil

    var body: some View {
        NavigationStack {
            Group {
                if vm.habits.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        Text("Minimal Habit").font(.title2)
                        Text("Erstelle dein erstes Habit").foregroundStyle(.secondary)
                        Button("Neues Habit") { editHabit = nil; showingEditor = true }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(vm.habits) { habit in
                            NavigationLink(destination: HabitDetailView(habit: habit)) {
                                HabitRowView(habit: habit, onToggle: { vm.toggleToday(habit) })
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { vm.delete(habit) } label: { Label("Löschen", systemImage: "trash") }
                                Button { editHabit = habit; showingEditor = true } label: { Label("Bearbeiten", systemImage: "pencil") }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { editHabit = nil; showingEditor = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingEditor, onDismiss: { vm.load() }) {
                EditHabitView(habit: editHabit)
            }
        }
        .onAppear { vm.load() }
    }
}

