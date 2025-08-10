# Minimal Habit – Technisches Konzept & Umsetzungsplan (Final)

**Produktvision**\
Minimal Habit ist ein vollständig **offline**-fähiger Habit‑Tracker mit Streak‑Fokus. Keine Accounts, keine Server, keine Tracker. Daten bleiben lokal, optional verschlüsselt. Ziel: in <2 Sekunden von Appstart zum ersten Check‑in.

---

## 0) Name & Store‑Rahmen

- App‑Name: **Minimal Habit**
- Subtitel: *Offline Habit Tracker*
- Keywords (ASO): "habit, streak, offline, tracker, routine, minimal, focus" (Deutsch + Englisch lokalisieren)
- Preisstrategie: Free + **Pro Einmalkauf** (Tier 4–7), keine Abos. Einmalzahlung schaltet Limits & Branding aus.

---

## 1) Funktionsumfang (Scope)

**MUSS**

- Habits anlegen/bearbeiten/archivieren (Name, Farbe, Erinnerung optional)
- Tägliches Abhaken (heute + rückwirkend)
- Streaks: aktuelle & beste Serie, Erfüllungsquote
- Monatskalender‑Ansicht je Habit
- Lokale Erinnerungen pro Habit
- Export/Import: JSON + QR (Versioniert)
- Share‑Bild (Streak‑Karte) — Free mit Branding, Pro ohne
- Dunkel/Hell‑Modus

**SOLLTE**

- Sortierung/Pinning von Habits
- Mehrere App‑Themen (Pro)
- Einfache Onboarding‑Tour (3 Screens)

**NICHT (MVP)**

- Cloud‑Sync, Widgets, Watch‑App, Gamification‑Shop, Social Feed

---

## 2) Informationsarchitektur & Datenmodell

### 2.1 Entitäten (Core Data)

- **HabitEntity**

  - `id: UUID` (Primary Key, indexed)
  - `name: String` (1–40)
  - `colorHex: String` (z. B. `#5B8DEF`)
  - `reminderTime: Date?` (nur Uhrzeitanteil relevant → zusätzlich `reminderMinutes: Int?` 0..1439 für Stabilität)
  - `isArchived: Bool` (default false)
  - `createdAt: Date`
  - `updatedAt: Date`

- **HabitLogEntity**

  - `id: UUID`
  - `habitID: UUID` (FK, indexed)
  - `dayIndex: Int32` (Format `YYYYMMDD`, z. B. 20250810; **unique (habitID, dayIndex)**)
  - `isDone: Bool` (default true)
  - `timestamp: Date` (letzte Änderung)

**Indizes**: `HabitEntity.id`, `HabitEntity.isArchived`, `HabitLogEntity.habitID`, `HabitLogEntity.dayIndex`, unique composite (habitID, dayIndex).

**Migrations**: Start mit `Model v1`. Änderungen als Lightweight Migration (neu: Felder optional; keine Breaking‑Renames).

### 2.2 Ableitungen

- **Streak** = Folge aufeinanderfolgender `dayIndex`‑Tage mit `isDone==true`. Lücke bricht Serie.
- **CompletionRate** = erledigte Tage / mögliche Tage seit `createdAt` (oder konfigurierter Referenz).

### 2.3 Zeitlogik

- **dayIndex(Date)**: aus lokaler Zeit; `YYYY*10000 + MM*100 + DD`
- Mitternachtwechsel: am Gerätelokal. DST‑Wechsel robust, da Tages‑Index integerbasiert.
- Zeitzonenwechsel: aktueller Tag wechselt erst nach lokalem Mitternacht.

---

## 3) Architektur & Layering

- **Pattern**: SwiftUI + MVVM + Repository
- **Schichten**
  - UI (Views/Components)
  - ViewModels (State, Aktionen)
  - Repository (Core Data CRUD, Transaktionen, Idempotenz)
  - Services (Notifications, Export/Import, QR, Share, Seed, Analytics)
  - Utilities (Streak‑Berechnung, Date/Color‑Hilfen)
- **Threading**: ViewModels auf MainActor, Repository mit privaten Contexts (Background); Änderungen per `performAndWait`/`perform`.
- **DI**: `AppCoordinator` erstellt Singletons und injiziert über `Environment` / Initializer.

---

## 4) Projektstruktur & Dateien

```text
MinimalHabit/
├─ MinimalHabit.xcodeproj
├─ App/
│  ├─ MinimalHabitApp.swift
│  ├─ AppCoordinator.swift
│  ├─ AppState.swift
│  └─ SceneDelegate.swift (optional)
│
├─ Features/
│  ├─ Habits/
│  │  ├─ Models/ Habit.swift, HabitLog.swift
│  │  ├─ ViewModels/ HabitListViewModel.swift, HabitDetailViewModel.swift, EditHabitViewModel.swift
│  │  ├─ Views/ HabitListView.swift, HabitRowView.swift, HabitDetailView.swift, EditHabitView.swift, StreakCalendarView.swift
│  │  └─ Navigation/ HabitNavigator.swift
│  ├─ Stats/ ViewModels/StatsViewModel.swift  Views/StatsView.swift, StreakCardView.swift
│  └─ Settings/ ViewModels/SettingsViewModel.swift  Views/SettingsView.swift, ThemePickerView.swift, IconPickerView.swift, ReminderSettingsView.swift
│
├─ Services/
│  ├─ Persistence/ PersistenceController.swift, HabitRepository.swift, BackupExportService.swift
│  ├─ Notifications/ NotificationScheduler.swift
│  ├─ Sharing/ QRCodeService.swift, ShareImageRenderer.swift
│  ├─ Seed/ DailySeedProvider.swift
│  └─ Analytics/ LocalAnalytics.swift
│
├─ Utilities/
│  ├─ Extensions/ Date+Extensions.swift, Color+Extensions.swift, Collection+Safe.swift
│  └─ Helpers/ StreakCalculator.swift, Haptics.swift, AppConstants.swift
│
├─ UIComponents/ Buttons/PrimaryButton.swift  Cards/StreakCard.swift  Controls/HabitCheckmarkButton.swift  Modals/ConfirmDeleteSheet.swift
│
├─ Configurations/ Debug.xcconfig  Release.xcconfig
├─ Resources/ Assets.xcassets  Localizations/en.lproj,de.lproj  Info.plist  MinimalHabit.entitlements
├─ Tests/ MinimalHabitUnitTests/...  MinimalHabitUITests/...
└─ README.md
```

### 4.1 Zuständigkeiten & öffentliche APIs (Auszug)

**HabitRepository.swift**

```swift
protocol HabitRepository {
  func fetchHabits(includeArchived: Bool) -> [Habit]
  func habit(by id: UUID) -> Habit?
  func save(habit: Habit) throws
  func delete(habitID: UUID) throws
  @discardableResult
  func toggle(habitID: UUID, on dayIndex: Int) throws -> HabitStreakSnapshot
  func logs(habitID: UUID, in range: ClosedRange<Int>) -> [HabitLog]
}
```

**NotificationScheduler.swift**

```swift
func requestPermissionIfNeeded()
func scheduleDailyReminder(for habit: Habit)
func cancelReminder(for habitID: UUID)
func rescheduleAll(from habits: [Habit])
```

**BackupExportService.swift**

```swift
struct ExportPackage { let version: Int; let habits: [Habit]; let logs: [HabitLog] }
func exportAll() throws -> Data // JSON
func `import`(data: Data) throws -> ImportResult // merge by id + newer timestamp wins
```

**QRCodeService.swift**

```swift
func encode(_ package: ExportPackage) throws -> CGImage // QR
func decode(_ image: CGImage) throws -> ExportPackage
```

**ShareImageRenderer.swift**

```swift
func renderStreakCard(for habit: Habit, stats: StreakStats, pro: Bool) -> UIImage
```

**StreakCalculator.swift**

```swift
func currentStreak(days: Set<Int>) -> Int
func bestStreak(days: Set<Int>) -> Int
func completionRate(days: Set<Int>, since startIndex: Int) -> Double
```

---

## 5) UI/UX‑Spezifikation

### 5.1 Screens & Flows

1. **HabitListView**
   - Liste aktiver Habits: Name, Farbindikator, Tages‑Checkmark.
   - Toolbar: [+] neues Habit, [⋯] Menü → Stats, Einstellungen, Export.
   - Leere‑Zustand: „Erstelle dein erstes Habit“ mit Button.
2. **EditHabitView**
   - Felder: Name, Farbe (Palette), Erinnerung (Zeitpicker), Archivieren.
   - Buttons: Speichern, Löschen (mit Bestätigung).
3. **HabitDetailView**
   - Header: Name, Farbe, aktuelle/beste Serie.
   - **StreakCalendarView**: Grid des Monats; Tap toggelt Tag.
   - Footer: Share‑Karte erzeugen.
4. **StatsView**
   - Kennzahlen (aktuell/beste Serie, Rate), Verlauf mini.
5. **SettingsView**
   - Theme, Sprache, Pro‑Upgrade, Datenexport/import, Support.
6. **Onboarding (optional)**
   - 3 Slides: Offline‑Privacy, Streaks, Erinnerungen → Erlaubnisdialog.

### 5.2 Design‑Tokens

- **Typo**: SF Pro / System; Titel 28/semibold, Body 17/regular, Caption 13.
- **Farben**
  - `Primary`: #5B8DEF, `Accent`: #36C5F0
  - Graustufen systembasiert; Dark Mode automatisch.
- **Abstände**: 8/12/16/24 pt; Grid 4‑Basiseinheit.
- **Komponenten**: PrimaryButton (minHeight 44), CheckmarkButton (44×44, Hit‑Area ≥ 44).

### 5.3 Accessibility

- Dynamic Type AA, VoiceOver‑Labels, ausreichender Kontrast, Haptik (success/warning), Reduktion bewegter Elemente.

---

## 6) Erinnerungen (Lokale Notifications)

- Ein Reminder pro Habit (`reminderMinutes`).
- Planung: täglich um `reminderMinutes` lokaler Zeit, `UNCalendarNotificationTrigger` mit `repeats`.
- Änderungen an Zeit/Farbe/Name → `reschedule`.
- Appstart/Zeitzonenwechsel → `rescheduleAll`.
- Kategorie‑Aktion: „Erledigt markieren“ → Direkt‑Toggle (App‑Extension nicht nötig; Notification Action liefert Intent, App übernimmt).

---

## 7) Export/Import & QR

### 7.1 JSON‑Schema (Version 1)

```json
{
  "version": 1,
  "exportedAt": "2025-08-10T20:00:00Z",
  "habits": [
    {"id":"UUID","name":"Water","colorHex":"#5B8DEF","reminderMinutes":1200,"isArchived":false,"createdAt":"2025-08-01T08:00:00Z","updatedAt":"2025-08-10T18:00:00Z"}
  ],
  "logs": [
    {"id":"UUID","habitID":"UUID","dayIndex":20250810,"isDone":true,"timestamp":"2025-08-10T18:01:00Z"}
  ]
}
```

**Konfliktlösung**: Merge per `id`, Feld‑Weise Übernahme mit **neuerem **``**/**``.

### 7.2 QR‑Kodierung

- JSON → ggf. zlib‑komprimiert → Base64 → QR (Version auto).
- Große Datenmengen: Fallback auf Datei‑Share (ActivityViewController).

---

## 8) Monetarisierung (StoreKit)

- **Free**: max 3 Habits, Wasserzeichen im Share‑Bild, limitierte Themes.
- **Pro (IAP, non‑consumable)**: unbegrenzte Habits, kein Wasserzeichen, alle Themes.
- **Upgrade‑Flow**: In Settings & bei „+‑Limit erreicht“.
- **Restore Purchases**: in Settings.
- **Offline**: App funktioniert vollständig ohne Netz; Kauf/Restore benötigen Internet (OS‑Flow).
- **A/B**: entfällt, keine Server.

---

## 9) Qualität & Performance‑Budgets

- Kaltstart < 500 ms auf iPhone SE (aktuell)
- Toggle‑Latenz < 16 ms (60 fps)
- DB‑Operationen batched; Fetch auf Bedarf (NSFetchedResultsController/SwiftData‑Äquivalent für Live‑Updates)
- Speicher < 100 MB zur Laufzeit

---

## 10) Fehlerhandling & Telemetrie (lokal)

- **Fehlertypen**: `RepositoryError`, `ValidationError`, `ExportError`, `QRDecodeError`, `NotificationError`.
- **LocalAnalytics (nur lokal, JSON exportierbar)**
  - `app_open`, `habit_created`, `habit_deleted`, `toggle_success`, `toggle_undo`, `share_card_created`, `export_done`, `import_done`, `purchase_success`.
  - Rotationslog, Max 1 MB, FIFO‑Trunking.

---

## 11) Teststrategie

**Unit**

- StreakCalculator: aktuelle/beste Serie, Lücken, Monatskanten, Leap Year
- Date+Extensions: dayIndex Hin/Rückwandlung, Zeitzonenwechsel, DST
- Repository: Idempotenz `toggle`, Transaktionen, Merges
- Export/Import: Version 1 Roundtrip, Konfliktlösung korrekt
- Notifications: Zeitberechnung, Reschedule

**UI‑Tests**

- Onboarding → erstes Habit anlegen → Toggle heute → Detail → Share‑Bild
- Edit → Erinnerung setzen → Benachrichtigung tippen → App öffnet Correct
- Import via QR → Daten erscheinen

**Leistungs/Snapshot**

- Snapshot der StreakCard in Light/Dark, 3 Sprachen
- Startzeit‑Messung, Toggle‑Zeit

---

## 12) Lokalisierung

- Sprachen: EN, DE (MVP)
- `Localizable.strings` Schlüsselpräfixe: `habit_`, `stats_`, `settings_`, `onboarding_`
- Rechts‑nach‑Links kompatibel (AutoLayout/SwiftUI)

---

## 13) Sicherheit & Privacy

- Keine externen SDKs/Tracker
- Optional: **Datenverschlüsselung** (Future): App‑Passcode → Schlüssel im Keychain; DB‑Verschlüsselung via SQLCipher (nicht MVP)
- Privacy Policy: "Alle Daten bleiben lokal. Exporte sind Nutzer‑initiiert."

---

## 14) Store‑Assets (Plan)

- **Screenshots**: List, Detail‑Kalender, Share‑Card, Settings/Pro, Export/QR
- **Texte**: Kurzbeschreibung (<= 170 Zeichen), Langbeschreibung (3 Abschnitte: Offline, Einfach, Teilen)
- **App‑Icon**: Minimaler Haken auf farbigem Kreis, klare Silhouette, Dark‑Friendly

---

## 15) Roadmap

**Sprint 1 (Woche 1–2)**

- Core Data Stack, Modelle, Repository + Unit‑Tests
- HabitListView + EditHabitView (Create/Update/Delete)
- Toggle‑Flow + StreakCalculator

**Sprint 2 (Woche 3–4)**

- Detail‑Kalender + StatsView
- Notifications + RescheduleAll
- Export/Import JSON + QR

**Sprint 3 (Woche 5)**

- ShareImageRenderer + Branding (Free/Pro)
- Settings + Pro‑Kauf/Restore (StoreKit)

**Sprint 4 (Woche 6)**

- UI‑Polish, Accessibility, Lokalisierung EN/DE
- Snapshot/UI/Performance‑Tests; Release‑Checklist

---

## 16) Definition of Done & Release‑Checklist

- Alle Muss‑Features implementiert und mit Tests abgedeckt
- Crash‑free Sessions in internen Tests
- Startzeit und Toggle‑Latenz innerhalb Budget
- Lokalisierung gegengetestet (EN/DE), Screenshots erzeugt
- App Store Connect Einträge gefüllt, Privacy Nutrition Labels korrekt
- TestFlight (Internal) → (External) → Release

---

## 17) Offene Erweiterungen (nach MVP)

- Homescreen‑Widget, Watch‑App, CSV‑Import, Wochenziele, Notizen pro Tag, Backups in iCloud *optional und rein nutzerinitiierter Export*

---

## 18) Code‑Style & Konventionen (Kurz)

- SwiftLint (Zeilen ≤ 120, benannte Parameter, Enum‑Cases lowerCamel)
- Dateien ≤ 300 Zeilen, Views in Subviews extrahieren ab >150 Zeilen
- Pure Functions bevorzugen (StreakCalculator, Date Utils)

---

## 19) Akzeptanzkriterien (Detail)

- Toggle am aktuellen Tag erzeugt (oder löscht) genau **einen** Log für `(habitID, dayIndex)`.
- Streak‑Anzeige aktualisiert sich ohne App‑Neustart.
- Änderung der Erinnerung rescheduled exakt **eine** Notification pro Habit.
- Import führt niemals zu Duplikaten (unique constraint) und bevorzugt neuere Timestamps.
- Share‑Bild ist in Free gebrandet und in Pro nicht gebrandet.

---

## 20) Risiken & Gegenmaßnahmen

- **Zeitlogik/DST** → dayIndex statt 24h‑Sekunden, Tests für DST‑Wechsel
- **QR‑Größe** → Kompression + Dateishare‑Fallback
- **IAP‑Edge‑Cases** → Restore‑Button, Idempotenz der Unlock‑Flag
- **Core Data Locks** → Hintergrundkontexte, kleine Transaktionen, kein massives Main‑Thread‑Blockieren

