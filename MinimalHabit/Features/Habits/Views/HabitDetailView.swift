import SwiftUI

struct HabitDetailView: View {
    @StateObject private var vm: HabitDetailViewModel

    init(habit: Habit) {
        _vm = StateObject(wrappedValue: HabitDetailViewModel(habit: habit))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Circle().fill(Color(hex: vm.habit.colorHex)).frame(width: 14, height: 14)
                    Text(vm.habit.name).font(.title2).bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                StreakCalendarView(days: vm.monthDays, done: vm.doneDays) { idx in
                    vm.toggle(dayIndex: idx)
                }
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

