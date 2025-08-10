# Projektstatus – Minimal Habit

Stand: initiale Struktur migriert, Xcode-Projekt lauffähig, weitere Implementierung nach MD offen.

## Erledigt
- Projektstruktur gem. MD angelegt (`App/`, `Features/`, `Services/`, `Utilities/`, `UIComponents/`, `Resources/`, `Configurations/`, `Tests/`).
- Xcode-Projekt erstellt und korrigiert; jetzt auf Repo-Root (`MinimalHabit.xcodeproj`).
- Target auf iOS festgelegt (`SDKROOT=iphoneos`, `SUPPORTED_PLATFORMS=iphonesimulator iphoneos`).
- App-Entry (`App/MinimalHabitApp.swift`) → `HabitListView`.
- Platzhalter-Modelle (`Habit`, `HabitLog`) und InMemory-Repository.
- Utilities: `StreakCalculator`, `Date.dayIndex`.
- Stubs: `NotificationScheduler`, `QRCodeService` (Error-Stub), `ShareImageRenderer` (Placeholder), `PrimaryButton`.
- Ressourcen: `Info.plist` (CFBundleExecutable, APPL, LSRequiresIPhoneOS), `Assets.xcassets`, Entitlements (iOS leer).

## Offen (gemäß MD)
- Core Data Stack und `HabitRepository`-Implementierung (CRUD, Toggle idempotent, Indizes, Migrations v1).
- ViewModels: HabitList, HabitDetail, EditHabit (+ Navigation).
- Views: HabitRow, HabitDetail, EditHabit, StreakCalendar, StatsView, SettingsView, Theme/Icon/Reminder.
- Services: Export/Import JSON v1 (+ Konfliktlösung), QR encode/decode, ShareImageRenderer (Branding Free/Pro), NotificationScheduler mit UNUserNotificationCenter.
- Utilities: Color-Hex-Parser, Haptics, AppConstants, Collection+Safe, Date-Helper vollständig.
- Monetarisierung: StoreKit (non-consumable Pro, Restore, Limits Free).
- Lokalisierung: EN/DE, Localizable.strings-Struktur.
- Tests: Unit (StreakCalculator, Date, Repository, Export/Import, Notifications), UI/Snapshot/Performance.
- Configs: Debug/Release .xcconfig in Xcode verknüpfen (optional weitere Flags).

## Nächste sinnvolle Schritte
1) Core Data Stack + Repository v1.
2) HabitListViewModel + EditFlow (create/update/delete) mit UI.
3) Toggle-Flow + StreakCalendar.
4) Notifications + RescheduleAll.
5) Export/Import + QR.

Notiere hier neue Todos/Änderungen, damit wir synchron bleiben.
