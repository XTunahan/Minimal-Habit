# Minimal Habit – Projektstruktur

Diese Struktur folgt der Datei `minimal_habit_readme_struktur.md` und legt die Basis für SwiftUI + MVVM + Repository.

Verzeichnisse:

- App/: App‑Entry, AppCoordinator, AppState
- Features/: Feature‑Ordner (z. B. Habits → Models/ViewModels/Views)
- Services/: Persistenz, Notifications, Sharing, Seed, Analytics
- Utilities/: Extensions & Helper (z. B. StreakCalculator)
- UIComponents/: Wiederverwendbare UI‑Bausteine
- Resources/: Assets, Info.plist, Entitlements, Localizations
- Configurations/: Debug/Release‑xcconfig
- Tests/: Platzhalter für Unit/UI‑Tests

Hinweise:

- Aktuell existiert eine **InMemoryHabitRepository** als Platzhalter. Core Data folgt.
- Das alte Template unter `Minimal Habit/` wurde migriert (Entry → `App/MinimalHabitApp.swift`, List → `Features/Habits/Views/HabitListView.swift`).
- Die Xcode‑Projektdatei enthält keine verlinkten Quellen. Bitte in Xcode einmal die neuen Ordner hinzufügen (Add Files to …) oder ein neues Ziel erstellen und die Ordner referenzieren. Danach `Info.plist`, `Assets.xcassets` und `MinimalHabit.entitlements` im Target zuordnen.

