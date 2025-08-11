import SwiftUI

struct EditHabitView: View {
    @Environment(\.dismiss)
    ) private var dismiss
    @StateObject private var vm: EditHabitViewModel

    init(habit: Habit?) {
        _vm = StateObject(wrappedValue: EditHabitViewModel(habit: habit))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $vm.name)
                    TextField("Farbe (Hex)", text: $vm.colorHex)
                    Toggle("Archiviert", isOn: $vm.isArchived)
                }
                Section("Erinnerung (Minuten seit Mitternacht)") {
                    Stepper(value: Binding(get: { vm.reminderMinutes ?? 0 }, set: { vm.reminderMinutes = $0 }), in: 0...1439) {
                        Text(vm.reminderMinutes.map { "\($0)" } ?? "Aus")
                    }
                }
                if vm.existingID != nil {
                    Section { Button(role: .destructive) { try? vm.delete(); dismiss() } label: { Text("Löschen") } }
                }
            }
            .navigationTitle(vm.existingID == nil ? "Neues Habit" : "Habit bearbeiten")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { Button("Speichern") { try? vm.save(); dismiss() }.disabled(!vm.canSave) }
            }
        }
    }
}

