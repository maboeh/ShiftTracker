# ShiftTracker Roadmap

## Projektübersicht

**Ziel:** Transformation von ShiftTracker zu einer professionellen Schichtverfolgungs-App mit Export-Funktionalität und erweiterten Features

**Entwickler:** Solo-Entwicklung
**Plattform:** iPhone (iOS 17.6+)
**Timeline:** 15 Wochen (ca. 3.5 Monate)
**TestFlight-Release:** Nach Milestone 2 (Woche 7)

---

## App-Analyse und Ausgangslage

### Aktuelle Stärken
- Moderne Architektur mit SwiftUI und SwiftData
- Saubere MVVM-Struktur
- Reaktives UI-Design
- Basis-Funktionalität komplett (Ein-/Ausstempeln, Schichttypen, Wochenstatistiken)

### Kritische Verbesserungsbereiche (alle behoben)
1. ~~**Code-Qualität:** Duplizierte Header, Magic Numbers, hardcodierte Strings~~ ✅
2. ~~**Testing:** 0% Test-Abdeckung, keine CI/CD Pipeline~~ ✅ (142 Tests, CI/CD aktiv)
3. ~~**Sicherheit:** Keine Authentifizierung, keine Verschlüsselung~~ ✅
4. ~~**Funktionalität:** Keine Export-Funktion, keine Pausen-Verfolgung~~ ✅
5. ~~**Barrierefreiheit:** Keine Accessibility Labels, kein VoiceOver-Support~~ ✅

---

## Milestone 1: Stabilisierung & Qualitätssicherung ✅ ABGESCHLOSSEN
**Dauer:** 3 Wochen (Woche 1-3)
**Priorität:** KRITISCH - Fundament für alle weiteren Entwicklungen

### Phase 1.1: Code-Qualität verbessern ✅

#### To-Dos:
- [x] **Duplizierte Header-Kommentare bereinigen** ✅
  - `ShiftTracker/ActionButton.swift` (Zeilen 8-20 entfernen)
  - `ShiftTracker/EmptyStateView.swift` (Zeilen 8-13 entfernen)

- [x] **AppConfiguration.swift erstellen** ✅
  - Neue Datei: `ShiftTracker/Configuration/AppConfiguration.swift`
  - Alle Magic Numbers durch Konstanten ersetzt

- [x] **AppStrings.swift für Lokalisierung erstellen** ✅
  - Neue Datei: `ShiftTracker/Localization/AppStrings.swift`
  - Alle hardcodierten Strings zentralisiert

- [x] **ErrorHandler.swift implementieren** ✅
  - Neue Datei: `ShiftTracker/Services/ErrorHandler.swift`
  - Fehler-Typen: DatabaseError, ExportError, ValidationError, SecurityError, UnknownError
  - `.errorAlert()` View-Modifier für globale Fehleranzeige

### Phase 1.2: Testing Infrastructure ✅

#### To-Dos:
- [x] **Test-Target erstellen** ✅
  - ShiftTrackerTests Target zum Projekt hinzugefügt

- [x] **Unit Tests - Shift-Logik** ✅
  - `ShiftTrackerTests/ShiftTests.swift` (8 Tests)

- [x] **Unit Tests - Statistik-Berechnungen** ✅
  - `ShiftTrackerTests/WeekStatsTests.swift` (8 Tests)

- [x] **Unit Tests - Color-Extension** ✅
  - `ShiftTrackerTests/ColorExtensionTests.swift` (13 Tests)

- [x] **Unit Tests - Export-Optionen** ✅
  - `ShiftTrackerTests/ExportOptionsTests.swift`

- [x] **Mock-Objekte für SwiftData** ✅
  - `ShiftTrackerTests/Mocks/MockShift.swift` (Factory: completed, active, withBreaks, onDate)
  - `ShiftTrackerTests/Mocks/MockShiftType.swift` (Presets: frueh, spaet, nacht + withRate)
  - `ShiftTrackerTests/Mocks/TestContainer.swift` (In-Memory ModelContainer)
  - `ShiftTrackerTests/MockTests.swift` (9 Tests)

- [x] **CI/CD Pipeline konfigurieren** ✅
  - `.github/workflows/tests.yml` mit Code Coverage
  - Automatische Tests bei jedem Push/PR

- [x] **Umfassende Test-Suite** ✅
  - `ShiftTrackerTests/AuthManagerTests.swift` (12 Tests)
  - `ShiftTrackerTests/KeychainManagerTests.swift` (7 Tests)
  - `ShiftTrackerTests/AppConfigurationTests.swift` (8 Tests)
  - `ShiftTrackerTests/ErrorHandlerTests.swift` (8 Tests)
  - `ShiftTrackerTests/MailTemplatesTests.swift` (7 Tests)
  - `ShiftTrackerTests/ExportManagerTests.swift` (5 Tests)
  - `ShiftTrackerTests/PDFExporterTests.swift` (4 Tests)
  - `ShiftTrackerTests/EncryptionTests.swift` (8 Tests)
  - `ShiftTrackerTests/ShiftTemplateTests.swift` (5 Tests)
  - `ShiftTrackerTests/ExportRecordTests.swift` (3 Tests)
  - `ShiftTrackerTests/BreakTests.swift` (11 Tests)
  - `ShiftTrackerTests/CSVExporterTests.swift` (13 Tests)
  - **Gesamt: 142 Tests, alle bestanden**

### Phase 1.3: Barrierefreiheit ✅

#### To-Dos:
- [x] **Accessibility Labels hinzufügen** ✅
  - ActionButton, WeekStatsCard, EmptyStateView

- [x] **VoiceOver-Optimierung** ✅
  - accessibilityLabel für alle interaktiven Elemente
  - accessibilityHidden(true) für dekorative Icons
  - accessibilityElement(children: .combine) für zusammengehörige Elemente
  - Optimiert in: ContentView, SettingsView, StatsView, PINEntryView, AuthView, OnboardingView, TemplatesView, ExportView, EarningsCalculatorView

- [x] **Dynamic Type Support** ✅
  - EmptyStateView mit `.dynamicTypeSize(...DynamicTypeSize.accessibility1)`
  - Dekorative SF Symbols behalten feste Größen (beabsichtigt)

- [x] **Haptisches Feedback** ✅
  - `ShiftTracker/Services/HapticFeedback.swift`
  - Bei Ein-/Ausstempeln, Export-Erfolg, Fehlern

### Erfolgskriterien Milestone 1:
- ✅ 0 Linter-Warnungen
- ✅ Test-Abdeckung: 142 Tests, 18 Test-Suites
- ✅ Alle Accessibility Labels vorhanden
- ✅ CI/CD Pipeline läuft erfolgreich
- ✅ Code Review durchgeführt

---

## Milestone 2: Export-Funktionalität ✅ ABGESCHLOSSEN
**Dauer:** 4 Wochen (Woche 4-7)
**Priorität:** HOCH - USP für TestFlight-Release

### Phase 2.1: Export-Architektur ✅

#### To-Dos:
- [x] **Export-Ordnerstruktur erstellen** ✅
  - `ShiftTracker/Export/` mit 5 Dateien

- [x] **ExportManager.swift implementieren** ✅
  - Async export mit CSV/PDF-Unterstützung
  - Verschlüsselungs-Integration (AES-GCM + HKDF)
  - ExportRecord-Erstellung im ModelContext

- [x] **ExportOptions.swift definieren** ✅
  - ExportField (date, startTime, endTime, duration, shiftType, breakTime)
  - ExportFormat (csv, pdf)
  - DateRangePreset (thisWeek, thisMonth, lastMonth, thisYear, custom)
  - encryptionPassword-Option

- [x] **ExportValidator.swift erstellen** ✅
  - Validierung: leere Listen, leere Felder, Datumsfilterung

### Phase 2.2: CSV-Exporter ✅

#### To-Dos:
- [x] **CSVExporter.swift implementieren** ✅
  - UTF-8 mit BOM, Semikolon-Separator, Sonderzeichen-Escaping

- [x] **CSV-Export-View erstellen** ✅
  - Format-Auswahl, Zeitraum, Felder-Konfiguration, Verschlüsselungs-Option

- [x] **Unit Tests für CSV-Exporter** ✅
  - 13 Tests in CSVExporterTests.swift

### Phase 2.3: PDF-Generator ✅

#### To-Dos:
- [x] **PDFKit Integration** ✅
  - A4-Layout mit Header, Tabelle, Zusammenfassung, Footer
  - Mehrseitige PDFs mit Seitenumbruch

- [x] **PDF-Vorschau-View** ✅
  - `ShiftTracker/Views/PDFPreviewView.swift` mit Share-Button

### Phase 2.4: Mail-Export ✅

#### To-Dos:
- [x] **MessageUI Framework integrieren** ✅
  - `ShiftTracker/Mail/MailComposerView.swift`

- [x] **E-Mail-Vorlagen erstellen** ✅
  - `ShiftTracker/Mail/MailTemplates.swift`
  - Wochenbericht, Monatsbericht, Benutzerdefiniert

- [x] **E-Mail-Verfügbarkeit prüfen** ✅
  - Fallback auf Share Sheet wenn Mail nicht verfügbar

- [x] **Export-Button in ContentView integrieren** ✅

### Phase 2.5: Share-Funktionalität ✅

#### To-Dos:
- [x] **Share Sheet Integration** ✅
  - `ShiftTracker/Share/ShareSheetView.swift`

- [x] **Export-Historie implementieren** ✅
  - `ShiftTracker/Export/ExportRecord.swift` (SwiftData @Model)
  - Letzte 10 Exporte in ExportView angezeigt

### Phase 2.6: TestFlight-Vorbereitung

#### Erledigt:
- [x] **App Icon und Assets** ✅
  - 32 Icon-PNGs in allen erforderlichen Größen (1024x1024 Master + iOS/watchOS)
  - App Icon in Assets.xcassets korrekt konfiguriert
  - Launch Screen konfiguriert

#### Noch zu erledigen (manuell in Xcode / App Store Connect):

- [ ] **Schritt 1: App Store Connect einrichten**
  - Öffne [App Store Connect](https://appstoreconnect.apple.com)
  - "Meine Apps" → "+" → "Neue App"
  - Bundle ID: `maboeh.com.ShiftTracker`
  - Name: "ShiftTracker"
  - Primäre Sprache: Deutsch
  - SKU: z.B. `shifttracker-2026`

- [ ] **Schritt 2: App Privacy Details ausfüllen**
  - App Store Connect → App → "App-Datenschutz"
  - "Keine Daten erfasst" auswählen (alle Daten bleiben lokal auf dem Gerät)

- [ ] **Schritt 3: Archive erstellen und hochladen**
  - In Xcode: Product → Archive (Scheme: ShiftTracker, Destination: Any iOS Device)
  - Nach dem Archive: "Distribute App" → "App Store Connect" → "Upload"
  - Alternativ via Terminal:
    ```bash
    xcodebuild archive \
      -project ShiftTracker.xcodeproj \
      -scheme ShiftTracker \
      -archivePath build/ShiftTracker.xcarchive

    xcodebuild -exportArchive \
      -archivePath build/ShiftTracker.xcarchive \
      -exportOptionsPlist ExportOptions.plist \
      -exportPath build/export
    ```

- [ ] **Schritt 4: TestFlight aktivieren**
  - App Store Connect → App → "TestFlight" Tab
  - Build erscheint nach 5-15 Min. Verarbeitung
  - "Exportbestimmungen" beantworten (Verschlüsselung: Ja, Standard-Encryption → HTTPS/AES)
  - Interne Tester-Gruppe anlegen und Tester einladen
  - Release Notes schreiben, z.B.:
    > ShiftTracker 1.0.0 Beta
    > - Schichten ein-/ausstempeln mit Pausen-Tracking
    > - Interaktive Home Screen & Lock Screen Widgets
    > - Live Activity mit Dynamic Island
    > - CSV/PDF Export mit optionaler Verschlüsselung
    > - Wochenstatistiken und Verdienstrechner
    > - Face ID / Touch ID / PIN-Schutz

### Erfolgskriterien Milestone 2:
- ✅ CSV-Export funktioniert für alle Zeiträume
- ✅ PDF-Export mit professionellem Layout
- ✅ Mail-Export mit Vorlagen
- ✅ Share Sheet für alle Optionen
- [ ] TestFlight Build verfügbar
- [ ] Mind. 5 Beta-Tester eingeladen

---

## Milestone 3: Pausen-Verfolgung ✅ ABGESCHLOSSEN
**Dauer:** 3 Wochen (Woche 8-10)
**Priorität:** HOCH - Must-Have Feature

### Phase 3.1: Datenmodell erweitern ✅

#### To-Dos:
- [x] **Break.swift Modell erstellen** ✅
  - `ShiftTracker/Break.swift` mit duration, isActive, @Relationship zu Shift

- [x] **Shift.swift erweitern** ✅
  - breaks-Relationship mit cascade delete
  - netDuration, totalBreakDuration, hasActiveBreak computed properties

- [x] **SwiftData Migration** ✅
  - Lightweight Migration funktioniert

### Phase 3.2: UI für Pausen ✅

#### To-Dos:
- [x] **ActionButton erweitern (3-Zustände)** ✅
  - ShiftState: inactive, active, onBreak
  - Kontextabhängige Farben und Labels

- [x] **BreakListView.swift erstellen** ✅
  - Liste aller Pausen mit SwipeActions zum Löschen

- [x] **ShiftDetailView erweitern** ✅
  - Pausen-Section mit Gesamtpausenzeit und Netto-Arbeitszeit

- [x] **BreakEditView.swift erstellen** ✅
  - Start-/Endzeit bearbeiten mit Validierung

### Phase 3.3: Pausen-Statistiken ✅

#### To-Dos:
- [x] **WeekStatsCard erweitern** ✅
  - Schichtanzahl und Pausen-Minuten angezeigt

- [x] **Pausen-Warnungen implementieren** ✅
  - Erinnerung nach 6h ohne Pause via NotificationManager

### Phase 3.4: Export mit Pausen ✅

#### To-Dos:
- [x] **CSV-Exporter erweitern** ✅
  - breakTime und netDuration als ExportFields

- [x] **PDF-Exporter erweitern** ✅
  - Pausen in Tabelle und Zusammenfassung

### Erfolgskriterien Milestone 3:
- ✅ Pausen können hinzugefügt, bearbeitet und gelöscht werden
- ✅ Netto-Arbeitszeit wird korrekt berechnet
- ✅ Pausen-Statistiken sind verfügbar
- ✅ Export enthält Pausen-Informationen
- ✅ Pausen-Warnungen funktionieren

---

## Milestone 4: Sicherheit & Authentifizierung ✅ ABGESCHLOSSEN
**Dauer:** 2 Wochen (Woche 11-12)
**Priorität:** MITTEL - Schutz sensibler Daten

### Phase 4.1: Biometrie-Authentifizierung ✅

#### To-Dos:
- [x] **LocalAuthentication integrieren** ✅
  - `ShiftTracker/Services/AuthManager.swift`
  - Face ID / Touch ID mit Fallback auf PIN

- [x] **Biometrie-Typ erkennen** ✅
  - canEvaluatePolicy(), biometryType-Erkennung

- [x] **Auth-UI erstellen** ✅
  - `ShiftTracker/Views/AuthView.swift`
  - Login-Screen mit Biometrie und PIN-Fallback

### Phase 4.2: PIN-Code System ✅

#### To-Dos:
- [x] **PIN-Setup implementieren** ✅
  - `ShiftTracker/Views/PINSetupView.swift`
  - 4-6 stelliger PIN mit Bestätigung
  - Schwache PINs werden erkannt (0000, 1234, etc.)

- [x] **PIN-Validierung** ✅
  - `ShiftTracker/Views/PINEntryView.swift`
  - Lockout nach 5 Fehlversuchen

- [x] **PIN in Keychain speichern** ✅
  - `ShiftTracker/Services/KeychainManager.swift`
  - SHA-256 Hash im Keychain gespeichert

### Phase 4.3: Auto-Lock und Datenschutz ✅

#### To-Dos:
- [x] **Auto-Lock Timer** ✅
  - Konfigurierbar: Sofort, 1 Min, 2 Min, 5 Min
  - Background/Foreground-Tracking in AuthManager
  - SecuritySettingsView mit Picker

- [x] **Datenschutz-Hinweise** ✅
  - Integriert als 5. Onboarding-Page
  - Kernpunkte: lokale Datenspeicherung, keine Cloud, kein Tracking

### Phase 4.4: Datenverschlüsselung ✅

#### To-Dos:
- [x] **CryptoKit Integration** ✅
  - `ShiftTracker/Services/EncryptionManager.swift`
  - AES-GCM mit HKDF-Schlüsselableitung und 16-Byte Random Salt

- [x] **Verschlüsselter Export** ✅
  - Passwort-geschützter Export (.enc-Dateien)
  - Passwort-Bestätigungsfeld in ExportView

### Erfolgskriterien Milestone 4:
- ✅ Face ID/Touch ID funktioniert
- ✅ PIN-Code als Fallback verfügbar
- ✅ Auto-Lock nach konfigurierbarer Inaktivität
- ✅ AES-GCM Verschlüsselung für Exports
- ✅ Datenschutzerklärung im Onboarding

---

## Milestone 5: UX-Polish & Erweiterte Features ✅ ABGESCHLOSSEN (bis auf Release)
**Dauer:** 3 Wochen (Woche 13-15)
**Priorität:** MITTEL - Optimierung für Produktions-Release

### Phase 5.1: Einstellungen und Personalisierung ✅

#### To-Dos:
- [x] **Settings via AppStorage/UserDefaults** ✅
  - Wochenstunden-Ziel, Stundenlohn, Benachrichtigungen, Sicherheit
  - Kein separates SwiftData-Model nötig (AppStorage ausreichend)

- [x] **SettingsView.swift erstellen** ✅
  - Sections: Arbeitszeit, Benachrichtigungen, Sicherheit, Verwaltung, Info

- [x] **Settings in Navigation integrieren** ✅
  - Gear-Icon in ContentView Toolbar

### Phase 5.2: Schichttyp-Verwaltung ✅

#### To-Dos:
- [x] **ShiftTypeManagementView.swift** ✅
  - Liste, Hinzufügen, Bearbeiten, Löschen mit Bestätigungsdialog

- [x] **ShiftTypeEditView.swift** ✅
  - Name, Farbe (ColorPicker), optionaler Stundenlohn

- [x] **Schichttyp-spezifische Löhne** ✅
  - ShiftType.hourlyRate (optional, Fallback auf globalen Lohn)
  - Aufschlüsselung nach Typ in EarningsCalculatorView

### Phase 5.3: Erweiterte Statistiken mit Charts ✅

#### To-Dos:
- [x] **Swift Charts integrieren** ✅
  - `import Charts` in StatsView

- [x] **StatsView.swift erstellen** ✅
  - Monatsansicht mit Balkendiagramm (tägliche Stunden)
  - Jahresansicht mit Balkendiagramm (monatliche Stunden)
  - Accessibility Labels für Chart-Daten

- [x] **EarningsCalculatorView.swift** ✅
  - Konfigurierbarer Stundenlohn
  - Verdienst pro Woche/Monat/Jahr
  - Aufschlüsselung nach Schichttyp mit typ-spezifischen Löhnen

### Phase 5.4: Benachrichtigungen und Erinnerungen ✅

#### To-Dos:
- [x] **UserNotifications konfigurieren** ✅
  - Berechtigungen in NotificationManager

- [x] **NotificationManager.swift erstellen** ✅
  - `ShiftTracker/Services/NotificationManager.swift`

- [x] **Benachrichtigungs-Typen implementieren** ✅
  - **Pausen-Erinnerung:** Nach 6h Netto-Arbeitszeit
  - **Schichtdauer-Erinnerung:** Nach konfigurierbarer Stundenzahl
  - **Vergessenes Ausstempeln:** Nach 10h (UNTimeIntervalNotificationTrigger)
  - **Wochenbericht:** Freitag 17:00 (UNCalendarNotificationTrigger)

- [x] **Benachrichtigungs-Einstellungen** ✅
  - Toggles in SettingsView für jeden Typ

### Phase 5.5: Schichtvorlagen ✅

#### To-Dos:
- [x] **ShiftTemplate.swift Modell** ✅
  - `ShiftTracker/ShiftTemplate.swift`
  - name, shiftType, defaultStartHour/Minute, defaultDurationHours

- [x] **TemplatesView.swift erstellen** ✅
  - Liste, Hinzufügen (TemplateAddView), Swipe-to-Delete

- [x] **Vorlage anwenden** ✅
  - "Aus Vorlage"-Button in ContentView
  - startShiftFromTemplate() mit shiftType-Übernahme

### Phase 5.6: Onboarding und Hilfe ✅

#### To-Dos:
- [x] **OnboardingView.swift erstellen** ✅
  - 5 Screens: Willkommen, Pausen, Statistiken, Sicherheit, Datenschutz
  - TabView mit Paging, Überspringen-Button

- [x] **Onboarding-Logik** ✅
  - `@AppStorage("hasCompletedOnboarding")` in ShiftTrackerApp

- [x] **HelpView.swift erstellen** ✅
  - FAQ-Bereich mit DisclosureGroups
  - App-Info (Version, Build)

### Phase 5.7: Final Polish und Production Release (teilweise ausstehend)

#### To-Dos:
- [x] **Performance-Optimierung** ✅
  - "Älter"-Section auf 50 Einträge limitiert
  - completedShifts-Filter in EarningsCalculatorView
  - Animation für Export-History @Query

- [ ] **App Store Assets finalisieren**
  - Professionelle Screenshots (iPhone 14, 15, SE)
  - App Preview Videos erstellen
  - Marketing-Material vorbereiten

- [ ] **Production Build erstellen**
  - Version: 1.0.0 (Production)
  - Build-Nummer: Inkrementell
  - Release-Build mit Optimierungen
  - App Store Review einreichen

- [ ] **Release-Kommunikation**
  - App Store Beschreibung finalisieren
  - Release Notes schreiben
  - Beta-Tester über Release informieren

### Erfolgskriterien Milestone 5:
- ✅ Alle Settings funktionieren
- ✅ Erweiterte Statistiken mit Charts
- ✅ Benachrichtigungen konfigurierbar
- ✅ Schichtvorlagen verfügbar
- ✅ Onboarding für neue User
- [ ] App Store Release eingereicht

---

## Technische Spezifikationen

### Verwendete Frameworks:
- **SwiftUI** (UI) ✅
- **SwiftData** (Persistenz) ✅
- **LocalAuthentication** (Biometrie) ✅
- **MessageUI** (E-Mail) ✅
- **UserNotifications** (Benachrichtigungen) ✅
- **PDFKit** (PDF-Generierung) ✅
- **CryptoKit** (Verschlüsselung) ✅
- **Charts** (Statistiken) ✅
- **Security** (Keychain) ✅
- **WidgetKit** (Home Screen & Lock Screen Widgets) ✅
- **ActivityKit** (Live Activity & Dynamic Island) ✅
- **AppIntents** (Interaktive Widget-Buttons) ✅

### Dateistruktur (aktuell):
```
ShiftTracker/
├── Configuration/
│   └── AppConfiguration.swift
├── Localization/
│   └── AppStrings.swift
├── Shift.swift
├── ShiftType.swift
├── Break.swift
├── ShiftTemplate.swift
├── ShiftTrackerApp.swift
├── ShiftState.swift
├── ShiftTracker.entitlements
├── Services/
│   ├── ErrorHandler.swift
│   ├── HapticFeedback.swift
│   ├── AuthManager.swift
│   ├── KeychainManager.swift
│   ├── EncryptionManager.swift
│   ├── NotificationManager.swift
│   ├── ModelContainerProvider.swift
│   └── ShiftService.swift
├── Intents/
│   ├── StartShiftIntent.swift
│   ├── EndShiftIntent.swift
│   └── ToggleBreakIntent.swift
├── LiveActivity/
│   ├── ShiftActivityAttributes.swift
│   └── LiveActivityManager.swift
├── Export/
│   ├── ExportManager.swift
│   ├── CSVExporter.swift
│   ├── PDFExporter.swift
│   ├── ExportValidator.swift
│   ├── ExportOptions.swift
│   └── ExportRecord.swift
├── Mail/
│   ├── MailComposerView.swift
│   └── MailTemplates.swift
├── Share/
│   └── ShareSheetView.swift
├── Views/
│   ├── ContentView.swift
│   ├── ShiftDetailView.swift
│   ├── ShiftRow.swift
│   ├── WeekStatsCard.swift
│   ├── ActionButton.swift
│   ├── EmptyStateView.swift
│   ├── ExportView.swift
│   ├── PDFPreviewView.swift
│   ├── BreakListView.swift
│   ├── BreakEditView.swift
│   ├── StatsView.swift
│   ├── EarningsCalculatorView.swift
│   ├── AuthView.swift
│   ├── PINSetupView.swift
│   ├── PINEntryView.swift
│   ├── SecuritySettingsView.swift
│   ├── SettingsView.swift
│   ├── ShiftTypeManagementView.swift
│   ├── ShiftTypeEditView.swift
│   ├── TemplatesView.swift
│   ├── OnboardingView.swift
│   ├── HelpView.swift
│   └── ColorPreviewView.swift
└── ShiftTrackerTests/
    ├── ShiftTests.swift
    ├── BreakTests.swift
    ├── WeekStatsTests.swift
    ├── ColorExtensionTests.swift
    ├── ExportOptionsTests.swift
    ├── ExportValidatorTests.swift
    ├── CSVExporterTests.swift
    ├── PDFExporterTests.swift
    ├── ExportManagerTests.swift
    ├── ExportRecordTests.swift
    ├── EncryptionTests.swift
    ├── AuthManagerTests.swift
    ├── KeychainManagerTests.swift
    ├── AppConfigurationTests.swift
    ├── ErrorHandlerTests.swift
    ├── MailTemplatesTests.swift
    ├── ShiftTemplateTests.swift
    ├── ShiftServiceTests.swift
    ├── MockTests.swift
    └── Mocks/
        ├── TestContainer.swift
        ├── MockShift.swift
        └── MockShiftType.swift
ShiftTrackerWidget/
├── ShiftTrackerWidget.swift (@main WidgetBundle)
├── ShiftWidgetEntry.swift
├── ShiftWidgetProvider.swift
├── LockScreenWidget.swift
├── ShiftTrackerWidgetEntitlements.entitlements
├── Views/
│   ├── SmallWidgetView.swift
│   ├── MediumWidgetView.swift
│   ├── AccessoryCircularView.swift
│   └── AccessoryRectangularView.swift
└── LiveActivity/
    ├── ShiftLiveActivity.swift
    ├── ShiftLiveActivityView.swift
    └── DynamicIslandViews.swift
```

---

## Widget-System ✅ ABGESCHLOSSEN

**Implementiert:** 17.02.2026

### Architektur
- **App Group** `group.maboeh.com.ShiftTracker` für SharedContainer (SwiftData)
- **ShiftService** extrahierte Geschäftslogik aus ContentView (wiederverwendbar in App + Widget)
- **ModelContainerProvider** zentraler SwiftData-Container mit App Group Storage
- **App Intents** für interaktive Widget-Buttons (kein URL-Scheme)
- **`Text(.timer)`** für Echtzeit-Timer ohne Widget-Reloads

### Widgets
| Widget | Familie | Interaktiv | Beschreibung |
|--------|---------|-----------|--------------|
| Small | systemSmall | Nein | Status-Icon + Live-Timer |
| Medium | systemMedium | Ja | Status + Timer + Start/Pause/Ende Buttons |
| Lock Screen Circular | accessoryCircular | Nein | Kompaktes Icon + Mini-Timer |
| Lock Screen Rectangular | accessoryRectangular | Nein | Icon + Statustext + Timer |
| Live Activity | Lock Screen Banner | Ja | Timer + Pause/Ende Buttons |
| Dynamic Island | Compact/Minimal/Expanded | Ja | Status + Timer + Buttons (expanded) |

### Tests
- 17 neue ShiftService-Tests (Start, End, Break Toggle, State Query, Edge Cases)
- Gesamt: **159 Tests**

---

## Verbleibende Aufgaben (nur manuelle Release-Aufgaben)

| # | Aufgabe | Typ | Beschreibung |
|---|---------|-----|-------------|
| 1 | ~~App Icon & Assets~~ | ~~Manuell~~ | ✅ Erledigt (32 PNGs) |
| 2 | App Store Connect | Manuell | Neue App anlegen, Privacy Details |
| 3 | Archive & Upload | Manuell | Xcode Archive → TestFlight Upload |
| 4 | TestFlight Beta-Test | Manuell | Tester einladen, Release Notes |

---

## Erfolgsmetriken

### Technische Metriken (erreicht):
- ✅ Test-Abdeckung: 159 Tests in 19 Test-Suites
- ✅ Code-Qualität: 0 kritische Warnungen
- ✅ CI/CD: GitHub Actions mit Code Coverage
- ✅ Sicherheit: AES-GCM Verschlüsselung, Keychain, Biometrie
- ✅ Widgets: Home Screen (Small/Medium), Lock Screen, Live Activity, Dynamic Island

---

**Stand:** 17.02.2026
**Version:** 2.1
**Status:** Alle Code-Features inkl. Widget-System abgeschlossen. TestFlight-Upload ausstehend.
**Build:** ✅ BUILD SUCCEEDED
**Tests:** ✅ 159/159 PASSED
