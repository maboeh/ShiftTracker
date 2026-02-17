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

### Kritische Verbesserungsbereiche
1. **Code-Qualität:** Duplizierte Header, Magic Numbers, hardcodierte Strings
2. **Testing:** 0% Test-Abdeckung, keine CI/CD Pipeline
3. **Sicherheit:** Keine Authentifizierung, keine Verschlüsselung
4. **Funktionalität:** Keine Export-Funktion, keine Pausen-Verfolgung
5. **Barrierefreiheit:** Keine Accessibility Labels, kein VoiceOver-Support

---

## Milestone 1: Stabilisierung & Qualitätssicherung
**Dauer:** 3 Wochen (Woche 1-3)
**Priorität:** KRITISCH - Fundament für alle weiteren Entwicklungen

### Phase 1.1: Code-Qualität verbessern (3-4 Tage)

#### To-Dos:
- [x] **Duplizierte Header-Kommentare bereinigen** ✅
  - `ShiftTracker/ActionButton.swift` (Zeilen 8-20 entfernen)
  - `ShiftTracker/EmptyStateView.swift` (Zeilen 8-13 entfernen)
  - Zeit: 30 Minuten

- [x] **AppConfiguration.swift erstellen** ✅
  - Neue Datei: `ShiftTracker/Configuration/AppConfiguration.swift`
  - Alle Vorkommen von `40.0` in ContentView.swift ersetzt
  - Alle Vorkommen in WeekStatsCard.swift ersetzt
  - Zeit: 1 Stunde

- [x] **AppStrings.swift für Lokalisierung erstellen** ✅
  - Neue Datei: `ShiftTracker/Localization/AppStrings.swift`
  - Hardcodierten Benutzernamen "Matthias" durch generischen Text ersetzt
  - Zeit: 2 Stunden

- [x] **ErrorHandler.swift implementieren** ✅
  - Neue Datei: `ShiftTracker/Services/ErrorHandler.swift`
  - Try? durch try-catch mit Toast/Error-Alert ersetzen in:
    - ContentView.swift
  - Fehler-Typen definiert: ExportError, DatabaseError, ValidationError
  - Zeit: 3 Stunden

### Phase 1.2: Testing Infrastructure (5-6 Tage)

#### To-Dos:
- [x] **Test-Target erstellen** ✅
  - ShiftTrackerTests Target zum Projekt hinzugefügt
  - XCTest Framework konfiguriert
  - Zeit: 1 Stunde

- [x] **Unit Tests - Shift-Logik** ✅
  - Neue Datei: `ShiftTrackerTests/ShiftTests.swift`
  - Testfälle:
    - `testDurationCalculation()` ✅
    - `testDurationWithActiveShift()` ✅
    - `testNegativeDurationProtection()` ✅
    - `testShiftTypeAssignment()` ✅
  - Zeit: 3 Stunden

- [x] **Unit Tests - Statistik-Berechnungen** ✅
  - Neue Datei: `ShiftTrackerTests/WeekStatsTests.swift`
  - Testfälle:
    - `testWeeklyTotalHours()` ✅
    - `testOvertimeCalculation()` ✅
    - `testWeekProgress()` ✅
    - `testEmptyWeek()` ✅
  - Zeit: 3 Stunden

- [x] **Unit Tests - Color-Extension** ✅
  - Neue Datei: `ShiftTrackerTests/ColorExtensionTests.swift`
  - Testfälle:
    - `testValidHexColor()` ✅
    - `testInvalidHexColor()` ✅
    - `testHexWithHash()` ✅
    - `testHexWithoutHash()` ✅
  - Zeit: 2 Stunden

- [x] **Unit Tests - Export-Optionen** ✅
  - Neue Datei: `ShiftTrackerTests/ExportOptionsTests.swift`
  - Zeit: 2 Stunden

- [ ] **Mock-Objekte für SwiftData**
  - Neue Datei: `ShiftTrackerTests/Mocks/MockShift.swift`
  - Neue Datei: `ShiftTrackerTests/Mocks/MockShiftType.swift`
  - TestContainer erstellen
  - Zeit: 4 Stunden

- [ ] **CI/CD Pipeline konfigurieren**
  - GitHub Actions Workflow erstellen: `.github/workflows/tests.yml`
  - Automatische Tests bei jedem Pull Request
  - Code Coverage Reporting mit codecov.io
  - Zeit: 2 Stunden

### Phase 1.3: Barrierefreiheit (3-4 Tage)

#### To-Dos:
- [x] **Accessibility Labels hinzufügen** ✅
  - ActionButton.swift mit accessibilityLabel und accessibilityHint
  - WeekStatsCard.swift mit accessibilityLabel
  - EmptyStateView.swift mit accessibilityElement
  - Zeit: 3 Stunden

- [ ] **VoiceOver-Optimierung**
  - Accessibility Hints für alle interaktiven Elemente
  - Accessibility Values für dynamische Inhalte
  - Test mit VoiceOver (Settings → Accessibility → VoiceOver)
  - Zeit: 4 Stunden

- [ ] **Dynamic Type Support**
  - Alle `.font(.system(size: ...))` durch semantische Fonts ersetzen:
    - `.font(.headline)`
    - `.font(.body)`
    - `.font(.caption)`
  - Minimum Scale Factor setzen: `.minimumScaleFactor(0.5)`
  - Zeit: 2 Stunden

- [x] **Haptisches Feedback** ✅
  - Neue Datei: `ShiftTracker/Services/HapticFeedback.swift`
  - UINotificationFeedbackGenerator implementiert
  - Bei Ein-/Ausstempeln integriert
  - Bei Fehlern integriert
  - Zeit: 2 Stunden

### Erfolgskriterien Milestone 1:
- ✅ 0 Linter-Warnungen
- ✅ Test-Abdeckung >80%
- ✅ Alle Accessibility Labels vorhanden
- ✅ CI/CD Pipeline läuft erfolgreich
- ✅ Code Review durch Dritte (optional)

---

## Milestone 2: Export-Funktionalität ⭐
**Dauer:** 4 Wochen (Woche 4-7)
**Priorität:** HOCH - USP für TestFlight-Release
**TestFlight Release:** Ende Woche 7

### Phase 2.1: Export-Architektur (5-6 Tage)

#### To-Dos:
- [x] **Export-Ordnerstruktur erstellen** ✅
  - `ShiftTracker/Export/`
    - `ExportManager.swift`
    - `CSVExporter.swift`
    - `PDFExporter.swift`
    - `ExportValidator.swift`
    - `ExportOptions.swift`
  - Zeit: 30 Minuten

- [x] **ExportManager.swift implementieren** ✅
  - Protokoll definieren:
    ```swift
    protocol Exportable {
        func export(data: [Shift], options: ExportOptions) -> Result<URL, ExportError>
    }
    ```
  - ExportManager Klasse:
    ```swift
    class ExportManager {
        func export(format: ExportFormat, shifts: [Shift], options: ExportOptions) -> Result<URL, ExportError>
    }
    ```
  - Zeit: 3 Stunden

- [ ] **ExportOptions.swift definieren**
  - Struktur:
    ```swift
    struct ExportOptions {
        let includeHeaders: Bool
        let dateRange: DateInterval?
        let fields: [ExportField]
        let dateFormat: DateFormat
    }
    
    enum ExportField {
        case date, startTime, endTime, duration, shiftType, breakTime
    }
    
    enum ExportFormat {
        case csv, pdf
    }
    ```
  - Zeit: 1 Stunde

- [ ] **ExportValidator.swift erstellen**
  - Validierung:
    - Datenintegrität prüfen
    - Leere Shift-Liste abfangen
    - Datumsbereich validieren
    - Fehlermeldungen definieren
  - Zeit: 2 Stunden

### Phase 2.2: CSV-Exporter (4-5 Tage)

#### To-Dos:
- [ ] **CSVExporter.swift implementieren**
  - Basis-Funktionalität:
    ```swift
    class CSVExporter: Exportable {
        func export(data: [Shift], options: ExportOptions) -> Result<URL, ExportError> {
            // CSV-Header generieren
            // Daten-Zeilen erstellen
            // UTF-8 mit BOM für Excel
            // Datei speichern
        }
    }
    ```
  - Zeit: 4 Stunden

- [ ] **CSV-Format-Details**
  - Header: Datum, Start, Ende, Dauer, Schichttyp
  - Datumsformat: dd.MM.yyyy HH:mm
  - Dauer: HH:mm oder Dezimal
  - Sonderzeichen-Escaping (Komma, Anführungszeichen)
  - Zeilenumbrüche: \r\n für Windows-Kompatibilität
  - Zeit: 3 Stunden

- [ ] **CSV-Export-View erstellen**
  - Neue Datei: `ShiftTracker/Views/ExportView.swift`
  - UI-Elemente:
    - Export-Format wählen (CSV/PDF)
    - Zeitraum auswählen (Diese Woche, Dieser Monat, Benutzerdefiniert)
    - Felder konfigurieren (Checkboxen)
    - Vorschau-Button
    - Export-Button
  - Zeit: 4 Stunden

- [ ] **Unit Tests für CSV-Exporter**
  - Neue Datei: `ShiftTrackerTests/CSVExporterTests.swift`
  - Testfälle:
    - `testCSVGeneration()`
    - `testSpecialCharactersEscaping()`
    - `testEmptyShiftList()`
    - `testDateRangeFiltering()`
  - Zeit: 3 Stunden

### Phase 2.3: PDF-Generator (4-5 Tage)

#### To-Dos:
- [ ] **PDFKit Integration**
  - Framework importieren: `import PDFKit`
  - Neue Datei: `ShiftTracker/Export/PDFExporter.swift`
  - Basis-PDF-Erstellung:
    ```swift
    class PDFExporter: Exportable {
        func export(data: [Shift], options: ExportOptions) -> Result<URL, ExportError> {
            // PDF-Kontext erstellen
            // Seiten-Layout definieren
            // Tabellen rendern
            // Diagramme einbinden
        }
    }
    ```
  - Zeit: 6 Stunden

- [ ] **PDF-Design erstellen**
  - Header mit Logo und Titel
  - Tabellarische Schicht-Darstellung
  - Wochenstatistiken (Grafiken)
  - Footer mit Datum und Seitenzahl
  - Professionelles Layout für Arbeitgeber
  - Zeit: 5 Stunden

- [ ] **PDF-Vorschau-View**
  - Neue Datei: `ShiftTracker/Views/PDFPreviewView.swift`
  - PDFKit View verwenden: `PDFView(frame: ...)`
  - Zoom und Scroll-Funktionen
  - Share-Button direkt aus Vorschau
  - Zeit: 3 Stunden

### Phase 2.4: Mail-Export (4-5 Tage)

#### To-Dos:
- [ ] **MessageUI Framework integrieren**
  - Framework importieren: `import MessageUI`
  - Neue Datei: `ShiftTracker/Mail/MailComposerView.swift`
  - UIViewControllerRepresentable erstellen:
    ```swift
    struct MailComposerView: UIViewControllerRepresentable {
        @Binding var isPresented: Bool
        let subject: String
        let body: String
        let attachmentURL: URL?
        
        func makeUIViewController(context: Context) -> MFMailComposeViewController {
            let composer = MFMailComposeViewController()
            composer.setToRecipients([recipient])
            composer.setSubject(subject)
            composer.setMessageBody(body, isHTML: false)
            if let url = attachmentURL {
                let data = try Data(contentsOf: url)
                composer.addAttachmentData(data, mimeType: "text/csv", fileName: url.lastPathComponent)
            }
            return composer
        }
    }
    ```
  - Zeit: 4 Stunden

- [ ] **E-Mail-Vorlagen erstellen**
  - Neue Datei: `ShiftTracker/Mail/MailTemplates.swift`
  - Vorlagen:
    ```swift
    enum MailTemplate {
        case weeklyReport(WeekStats)
        case monthlyReport(MonthStats)
        case custom
        
        var subject: String { ... }
        var body: String { ... }
    }
    ```
  - Wochenbericht-Vorlage mit Statistiken
  - Monatsbericht-Vorlage mit Zusammenfassung
  - Benutzerdefinierte Vorlage
  - Zeit: 3 Stunden

- [ ] **E-Mail-Verfügbarkeit prüfen**
  - `MFMailComposeViewController.canSendMail()` prüfen
  - Fallback: Share Sheet wenn Mail nicht verfügbar
  - Fehlerbehandlung: "Kein E-Mail-Account konfiguriert"
  - Zeit: 1 Stunde

- [ ] **Export-Button in ContentView integrieren**
  - NavigationBar Toolbar-Item hinzufügen:
    ```swift
    .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showExportSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
    .sheet(isPresented: $showExportSheet) {
        ExportView()
    }
    ```
  - Zeit: 2 Stunden

### Phase 2.5: Share-Funktionalität (3-4 Tage)

#### To-Dos:
- [ ] **Share Sheet Integration**
  - Neue Datei: `ShiftTracker/Share/ShareSheetView.swift`
  - UIActivityViewController in SwiftUI einbinden:
    ```swift
    struct ShareSheetView: UIViewControllerRepresentable {
        let items: [Any]
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            UIActivityViewController(activityItems: items, applicationActivities: nil)
        }
    }
    ```
  - Zeit: 2 Stunden

- [ ] **Share-Optionen konfigurieren**
  - Available Activities: AirDrop, Mail, Nachrichten, Speichern
  - Excluded Activities: Post to Facebook, Twitter (nicht relevant)
  - Completion Handler für erfolgreiches Teilen
  - Zeit: 1 Stunde

- [ ] **Export-Historie implementieren**
  - Neue Datei: `ShiftTracker/Models/ExportHistory.swift`
  - Durchgeführte Exporte speichern (Datum, Format, Empfänger)
  - Letzte Exporte in Settings anzeigen
  - Wiederholte Exporte ermöglichen
  - Zeit: 3 Stunden

### Phase 2.6: TestFlight-Vorbereitung (2-3 Tage)

#### To-Dos:
- [ ] **App Icon und Assets**
  - Alle erforderlichen Icon-Größen erstellen (1024x1024, 180x180, etc.)
  - App Icon in Assets.xcassets einfügen
  - Launch Screen konfigurieren
  - Zeit: 3 Stunden

- [ ] **App Store Metadata**
  - App-Beschreibung (Deutsch)
  - Keywords: "Schicht, Arbeit, Stunden, Zeiterfassung, Überstunden"
  - Screenshots für verschiedene iPhone-Größen erstellen
  - App Privacy Details ausfüllen
  - Zeit: 2 Stunden

- [ ] **Build-Konfiguration**
  - Version: 1.0.0
  - Build-Nummer inkrementieren
  - Release-Build erstellen
  - Zeit: 1 Stunde

- [ ] **TestFlight-Upload**
  - App Store Connect: Neue App erstellen
  - Build hochladen
  - TestFlight-Beta-Tester einladen
  - Release Notes schreiben
  - Zeit: 2 Stunden

### Erfolgskriterien Milestone 2:
- ✅ CSV-Export funktioniert für alle Zeiträume
- ✅ PDF-Export mit professionellem Layout
- ✅ Mail-Export mit Vorlagen
- ✅ Share Sheet für alle Optionen
- ✅ TestFlight Build verfügbar
- ✅ Mind. 5 Beta-Tester eingeladen

---

## Milestone 3: Pausen-Verfolgung (Must-Have)
**Dauer:** 3 Wochen (Woche 8-10)
**Priorität:** HOCH - Must-Have Feature

### Phase 3.1: Datenmodell erweitern (3-4 Tage)

#### To-Dos:
- [ ] **Break.swift Modell erstellen**
  - Neue Datei: `ShiftTracker/Models/Break.swift`
  - Struktur:
    ```swift
    @Model
    class Break {
        var startTime: Date
        var endTime: Date?
        var shift: Shift?
        
        var duration: TimeInterval {
            if let end = endTime {
                return max(end.timeIntervalSince(startTime), 0)
            }
            return 0
        }
    }
    ```
  - Zeit: 1 Stunde

- [ ] **Shift.swift erweitern**
  - Neue Property: `var breaks: [Break]?`
  - Computed Property für Netto-Arbeitszeit:
    ```swift
    var netDuration: TimeInterval {
        let totalBreakTime = breaks?.reduce(0.0) { $0 + $1.duration } ?? 0
        return max(duration - totalBreakTime, 0)
    }
    ```
  - Zeit: 1 Stunde

- [ ] **SwiftData Migration**
  - Lightweight Migration für neue Property
  - Migration-Test mit bestehenden Daten
  - Zeit: 2 Stunden

### Phase 3.2: UI für Pausen (5-6 Tage)

#### To-Dos:
- [ ] **ActionButton erweitern (3-Zustände)**
  - Zustände: Ein-/Ausstempeln, Pause starten/beenden
  - Neues Design:
    ```swift
    enum ShiftState {
        case inactive
        case active
        case onBreak
    }
    ```
  - 3 Buttons in HStack oder Segment Control
  - Farbe: Grün (Ein), Gelb (Pause), Rot (Aus)
  - Zeit: 4 Stunden

- [ ] **BreakListView.swift erstellen**
  - Neue Datei: `ShiftTracker/Views/BreakListView.swift`
  - Liste aller Pausen einer Schicht
  - Hinzufügen/Bearbeiten/Löschen von Pausen
  - SwipeActions für schnelles Löschen
  - Zeit: 4 Stunden

- [ ] **ShiftDetailView erweitern**
  - Neue Section "Pausen":
    - BreakListView einbinden
    - Pause hinzufügen Button
    - Gesamtpausenzeit anzeigen
    - Netto-Arbeitszeit anzeigen
  - Zeit: 3 Stunden

- [ ] **BreakEditView.swift erstellen**
  - Neue Datei: `ShiftTracker/Views/BreakEditView.swift`
  - Start-/Endzeit bearbeiten
  - Validierung: Pause innerhalb Schichtzeit
  - Validierung: Pausen überschneiden sich nicht
  - Zeit: 3 Stunden

### Phase 3.3: Pausen-Statistiken (4-5 Tage)

#### To-Dos:
- [ ] **WeekStatsCard erweitern**
  - Zusätzliche Anzeige:
    - Gesamtpausenzeit pro Woche
    - Durchschnittliche Pausendauer
    - Netto-Arbeitszeit (abzüglich Pausen)
  - Neues Layout für zusätzliche Statistiken
  - Zeit: 3 Stunden

- [ ] **BreakStatsView.swift erstellen**
  - Neue Datei: `ShiftTracker/Views/BreakStatsView.swift`
  - Wochenübersicht der Pausen
  - Monatliche Pausen-Statistiken
  - Pausen-Compliance-Check:
    - Gesetzliche Pausenregelungen (DE: >6h = 30min, >9h = 45min)
    - Warnung bei fehlenden Pausen
  - Zeit: 5 Stunden

- [ ] **Pausen-Warnungen implementieren**
  - Timer-basierte Erinnerung nach 6h Arbeit ohne Pause
  - Lokale Benachrichtigung: "Du hast seit 6 Stunden keine Pause gemacht"
  - Einstellbar in Settings
  - Zeit: 3 Stunden

### Phase 3.4: Export mit Pausen (2-3 Tage)

#### To-Dos:
- [ ] **CSV-Exporter erweitern**
  - Neue Spalten: Pausen (Start, Ende, Dauer), Netto-Arbeitszeit
  - Optionale Pausen-Spalten in ExportOptions
  - Zeit: 2 Stunden

- [ ] **PDF-Exporter erweitern**
  - Pausen in Tabelle anzeigen
  - Brutto vs. Netto Arbeitszeit
  - Gesamtpausenzeit pro Woche/Monat
  - Zeit: 3 Stunden

### Erfolgskriterien Milestone 3:
- ✅ Pausen können hinzugefügt, bearbeitet und gelöscht werden
- ✅ Netto-Arbeitszeit wird korrekt berechnet
- ✅ Pausen-Statistiken sind verfügbar
- ✅ Export enthält Pausen-Informationen
- ✅ Pausen-Warnungen funktionieren

---

## Milestone 4: Sicherheit & Authentifizierung
**Dauer:** 2 Wochen (Woche 11-12)
**Priorität:** MITTEL - Schutz sensibler Daten

### Phase 4.1: Biometrie-Authentifizierung (4-5 Tage)

#### To-Dos:
- [ ] **LocalAuthentication integrieren**
  - Framework importieren: `import LocalAuthentication`
  - Neue Datei: `ShiftTracker/Services/AuthManager.swift`
  - Basis-Funktionalität:
    ```swift
    class AuthManager: ObservableObject {
        @Published var isAuthenticated = false
        
        func authenticateWithBiometrics() async -> Bool {
            let context = LAContext()
            // Face ID / Touch ID
        }
    }
    ```
  - Zeit: 3 Stunden

- [ ] **Biometrie-Typ erkennen**
  - Gerät unterstützen: Face ID, Touch ID, opticID (Vision Pro)
  - Fallback auf Geräte-PIN
  - Kompatibilitäts-Check: `canEvaluatePolicy()`
  - Zeit: 2 Stunden

- [ ] **Auth-UI erstellen**
  - Neue Datei: `ShiftTracker/Views/AuthView.swift`
  - Login-Screen mit App-Logo
  - "Mit Face ID anmelden" Button
  - Fallback: PIN-Eingabe
  - Zeit: 4 Stunden

### Phase 4.2: PIN-Code System (3-4 Tage)

#### To-Dos:
- [ ] **PIN-Setup implementieren**
  - Neue Datei: `ShiftTracker/Views/PINSetupView.swift`
  - 6-stelligen PIN erstellen
  - PIN bestätigen (2x eingeben)
  - PIN sicher in Keychain speichern (nicht UserDefaults!)
  - Zeit: 4 Stunden

- [ ] **PIN-Validierung**
  - Neue Datei: `ShiftTracker/Views/PINEntryView.swift`
  - PIN-Eingabe-Keypad (1-9, 0, Löschen)
  - Falsche PIN nach 3 Versuchen: Biometrie erzwingen
  - Zeit: 3 Stunden

- [ ] **PIN in Keychain speichern**
  - Neue Datei: `ShiftTracker/Services/KeychainManager.swift`
  - Sichere Speicherung mit Security framework
  - Zeit: 3 Stunden

### Phase 4.3: Auto-Lock und Datenschutz (2-3 Tage)

#### To-Dos:
- [ ] **Auto-Lock Timer**
  - Timer nach Inaktivität (1-5 Minuten, konfigurierbar)
  - SceneDelegate/WindowScene für Timer-Management
  - Bei Reaktivierung: Authentifizierung erforderlich
  - Zeit: 3 Stunden

- [ ] **Datenschutz-Hinweise**
  - Neue Datei: `ShiftTracker/Views/PrivacyPolicyView.swift`
  - Datenschutzerklärung beim ersten Start
  - Einwilligung speichern
  - App Privacy Details in Settings
  - Zeit: 2 Stunden

### Phase 4.4: Datenverschlüsselung (2-3 Tage)

#### To-Dos:
- [ ] **CryptoKit Integration**
  - Framework importieren: `import CryptoKit`
  - Neue Datei: `ShiftTracker/Services/EncryptionManager.swift`
  - Verschlüsselung für Backup-Export
  - Zeit: 4 Stunden

- [ ] **Sichere Backup-Funktion**
  - Export mit Passwort-Verschlüsselung
  - Backup-Wiederherstellung mit Passwort
  - Zeit: 3 Stunden

### Erfolgskriterien Milestone 4:
- ✅ Face ID/Touch ID funktioniert
- ✅ PIN-Code als Fallback verfügbar
- ✅ Auto-Lock nach Inaktivität
- ✅ Datenverschlüsselung für Backups
- ✅ Datenschutzerklärung implementiert

---

## Milestone 5: UX-Polish & Erweiterte Features
**Dauer:** 3 Wochen (Woche 13-15)
**Priorität:** MITTEL - Optimierung für Produktions-Release

### Phase 5.1: Einstellungen und Personalisierung (4-5 Tage)

#### To-Dos:
- [ ] **UserSettings.swift erstellen**
  - Neue Datei: `ShiftTracker/Models/UserSettings.swift`
  - SwiftData-Modell:
    ```swift
    @Model
    class UserSettings {
        var weeklyHoursTarget: Double = 40.0
        var userName: String = ""
        var defaultShiftType: ShiftType?
        var enableBreakReminders: Bool = true
        var autoLockMinutes: Int = 2
    }
    ```
  - Zeit: 2 Stunden

- [ ] **SettingsView.swift erstellen**
  - Neue Datei: `ShiftTracker/Views/SettingsView.swift`
  - Sections:
    - Profil (Name, Avatar)
    - Arbeitszeit (Wochenziel)
    - Standard-Schichttyp
    - Sicherheit (Auto-Lock, PIN ändern)
    - Benachrichtigungen
    - Datenschutz
    - Über die App
  - Zeit: 5 Stunden

- [ ] **Settings in Navigation integrieren**
  - NavigationLink zu SettingsView in ContentView
  - Toolbar-Item: Gear-Icon
  - Zeit: 1 Stunde

### Phase 5.2: Schichttyp-Verwaltung (3-4 Tage)

#### To-Dos:
- [ ] **ShiftTypeManagementView.swift**
  - Neue Datei: `ShiftTracker/Views/ShiftTypeManagementView.swift`
  - Liste aller Schichttypen
  - Hinzufügen/Bearbeiten/Löschen
  - Farbwähler für neue Typen
  - Zeit: 4 Stunden

- [ ] **ShiftTypeEditView.swift**
  - Neue Datei: `ShiftTracker/Views/ShiftTypeEditView.swift`
  - Name bearbeiten
  - Farbe wählen (ColorPicker)
  - Validierung: Name nicht leer, Farbe gültig
  - Zeit: 3 Stunden

- [ ] **ShiftType-Lösch-Logik**
  - Shifts mit diesem Typ auf "Kein Typ" setzen
  - Bestätigungsdialog
  - Zeit: 2 Stunden

### Phase 5.3: Erweiterte Statistiken mit Charts (5-6 Tage)

#### To-Dos:
- [ ] **Swift Charts integrieren**
  - Framework importieren: `import Charts` (iOS 16+)
  - Zeit: 30 Minuten

- [ ] **MonthlyStatsView.swift erstellen**
  - Neue Datei: `ShiftTracker/Views/MonthlyStatsView.swift`
  - Kalender-Heatmap für Schichtdichte
  - Wochenvergleich (Balkendiagramm)
  - Überstunden-Trend (Liniendiagramm)
  - Zeit: 6 Stunden

- [ ] **YearlyStatsView.swift erstellen**
  - Neue Datei: `ShiftTracker/Views/YearlyStatsView.swift`
  - Jahresübersicht mit Monatsvergleich
  - Jahresarbeitszeit gesamt
  - Vergleich mit Vorjahr
  - Zeit: 5 Stunden

- [ ] **EarningsCalculatorView.swift**
  - Neue Datei: `ShiftTracker/Views/EarningsCalculatorView.swift`
  - Stundenlohn konfigurierbar
  - Schichttyp-spezifische Löhne (z.B. Nachtschicht +25%)
  - Brutto-Verdienst berechnen
  - Export für Steuererklärung
  - Zeit: 5 Stunden

### Phase 5.4: Benachrichtigungen und Erinnerungen (4-5 Tage)

#### To-Dos:
- [ ] **UserNotifications konfigurieren**
  - Framework importieren: `import UserNotifications`
  - Berechtigungen anfordern
  - Zeit: 2 Stunden

- [ ] **NotificationManager.swift erstellen**
  - Neue Datei: `ShiftTracker/Services/NotificationManager.swift`
  - Funktionen:
    - `scheduleShiftReminder(for: Date)`
    - `scheduleForgotClockOutWarning()`
    - `scheduleWeeklySummary()`
  - Zeit: 4 Stunden

- [ ] **Benachrichtigungs-Typen implementieren**
  - **Schichtbeginn-Erinnerung:** 15 Min. vor geplanter Zeit
  - **Vergessenes Ausstempeln:** Nach 10h Arbeit
  - **Wochenbericht:** Jeden Freitag 17:00 Uhr
  - **Pausen-Erinnerung:** Nach 6h ohne Pause
  - Zeit: 5 Stunden

- [ ] **NotificationSettingsView.swift**
  - Neue Datei: `ShiftTracker/Views/NotificationSettingsView.swift`
  - Ein/Aus-Switches für jeden Typ
  - Zeiten konfigurierbar
  - Quiet Hours definieren
  - Zeit: 3 Stunden

### Phase 5.5: Schichtvorlagen (3-4 Tage)

#### To-Dos:
- [ ] **ShiftTemplate.swift Modell**
  - Neue Datei: `ShiftTracker/Models/ShiftTemplate.swift`
  - Struktur:
    ```swift
    @Model
    class ShiftTemplate {
        var name: String
        var startTime: Date // Nur Uhrzeit
        var endTime: Date
        var shiftType: ShiftType?
        var recurrenceDays: [Int] // 1=Mo, 7=So
    }
    ```
  - Zeit: 2 Stunden

- [ ] **TemplatesView.swift erstellen**
  - Neue Datei: `ShiftTracker/Views/TemplatesView.swift`
  - Liste aller Vorlagen
  - Vorlage erstellen/bearbeiten/löschen
  - Zeit: 4 Stunden

- [ ] **Vorlage anwenden**
  - Schnellerstellung aus Vorlage
  - Kontextmenü in ContentView: "Aus Vorlage erstellen"
  - Zeit: 3 Stunden

### Phase 5.6: Onboarding und Hilfe (3-4 Tage)

#### To-Dos:
- [ ] **OnboardingView.swift erstellen**
  - Neue Datei: `ShiftTracker/Views/OnboardingView.swift`
  - 3-4 Screens:
    1. Willkommen & App-Vorteile
    2. Erste Schicht erstellen (Tutorial)
    3. Einstellungen konfigurieren
    4. Authentifizierung einrichten (optional)
  - Zeit: 5 Stunden

- [ ] **Onboarding-Logik**
  - Wird nur beim ersten Start gezeigt
  - UserDefaults: `hasCompletedOnboarding`
  - Zeit: 1 Stunde

- [ ] **HelpView.swift erstellen**
  - Neue Datei: `ShiftTracker/Views/HelpView.swift`
  - FAQ-Bereich
  - Anleitungen mit Screenshots
  - Kontakt-Support
  - Zeit: 4 Stunden

### Phase 5.7: Final Polish und Production Release (2-3 Tage)

#### To-Dos:
- [ ] **Performance-Optimierung**
  - App-Start-Zeit messen und optimieren
  - Memory-Profiler laufen lassen
  - Lange Listen: Pagination implementieren
  - Zeit: 4 Stunden

- [ ] **App Store Assets finalisieren**
  - Professionelle Screenshots (iPhone 14, 15, SE)
  - App Preview Videos erstellen
  - Marketing-Material vorbereiten
  - Zeit: 4 Stunden

- [ ] **Production Build erstellen**
  - Version: 1.0.0 (Production)
  - Build-Nummer: Inkrementell
  - Release-Build mit Optimierungen
  - App Store Review einreichen
  - Zeit: 2 Stunden

- [ ] **Release-Kommunikation**
  - App Store Beschreibung finalisieren
  - Release Notes schreiben
  - Beta-Tester über Release informieren
  - Zeit: 2 Stunden

### Erfolgskriterien Milestone 5:
- ✅ Alle Settings funktionieren
- ✅ Erweiterte Statistiken mit Charts
- ✅ Benachrichtigungen konfigurierbar
- ✅ Schichtvorlagen verfügbar
- ✅ Onboarding für neue User
- ✅ App Store Release eingereicht

---

## Technische Spezifikationen

### Erforderliche Frameworks:
- **SwiftUI** (UI)
- **SwiftData** (Persistenz)
- **LocalAuthentication** (Biometrie)
- **MessageUI** (E-Mail)
- **UserNotifications** (Benachrichtigungen)
- **EventKit** (Kalenderintegration - Optional)
- **PDFKit** (PDF-Generierung)
- **CryptoKit** (Verschlüsselung)
- **Charts** (Statistiken)

### Dateistruktur (Endzustand):
```
ShiftTracker/
├── Configuration/
│   └── AppConfiguration.swift
├── Localization/
│   └── AppStrings.swift
├── Models/
│   ├── Shift.swift
│   ├── ShiftType.swift
│   ├── Break.swift
│   ├── UserSettings.swift
│   └── ShiftTemplate.swift
├── Services/
│   ├── ErrorHandler.swift
│   ├── HapticFeedback.swift
│   ├── AuthManager.swift
│   ├── KeychainManager.swift
│   ├── EncryptionManager.swift
│   └── NotificationManager.swift
├── Export/
│   ├── ExportManager.swift
│   ├── CSVExporter.swift
│   ├── PDFExporter.swift
│   ├── ExportValidator.swift
│   └── ExportOptions.swift
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
│   ├── BreakStatsView.swift
│   ├── AuthView.swift
│   ├── PINSetupView.swift
│   ├── PINEntryView.swift
│   ├── PrivacyPolicyView.swift
│   ├── SettingsView.swift
│   ├── ShiftTypeManagementView.swift
│   ├── ShiftTypeEditView.swift
│   ├── MonthlyStatsView.swift
│   ├── YearlyStatsView.swift
│   ├── EarningsCalculatorView.swift
│   ├── NotificationSettingsView.swift
│   ├── TemplatesView.swift
│   ├── OnboardingView.swift
│   └── HelpView.swift
└── Tests/
    └── ShiftTrackerTests/
        ├── ShiftTests.swift
        ├── WeekStatsTests.swift
        ├── ColorExtensionTests.swift
        ├── CSVExporterTests.swift
        ├── PDFExporterTests.swift
        └── Mocks/
            ├── MockShift.swift
            └── MockShiftType.swift
```

---

## Risikoanalyse und Mitigation

### Technische Risiken:

1. **SwiftData Migration**
   - Risiko: Datenverlust bei Modell-Änderungen
   - Mitigation: Lightweight Migration verwenden, Tests mit realen Daten
   - Zeitpunkt: Milestone 3 (Pausen-Modell)

2. **Export-Kompatibilität**
   - Risiko: CSV/PDF nicht kompatibel mit Excel/PDF-Readern
   - Mitigation: UTF-8 mit BOM, PDF/A-Standard, extensive Tests
   - Zeitpunkt: Milestone 2

3. **Biometrie-Geräteunterstützung**
   - Risiko: Geräte ohne Face ID/Touch ID
   - Mitigation: PIN-Fallback implementieren
   - Zeitpunkt: Milestone 4

### Timeline-Risiken:

1. **Solo-Entwickler Kapazität**
   - Risiko: Krankheit, andere Verpflichtungen
   - Mitigation: Puffer von 1-2 Wochen einplanen
   - Priorisierung: Export vor Sicherheit (Milestone 2 vor 4)

2. **Komplexitäts-Zuwachs**
   - Risiko: Features komplexer als geplant
   - Mitigation: MVP pro Milestone definieren, Features aufteilen
   - Fallback: Nicht-kritische Features auf v2.0 verschieben

---

## Erfolgsmetriken

### Technische Metriken:
- ✅ Test-Abdeckung: >80% (aktuell: 0%)
- ✅ Code-Qualität: 0 kritische Linter-Warnungen
- ✅ App-Start-Zeit: <2 Sekunden
- ✅ Memory-Verbrauch: <50 MB im Normalbetrieb
- ✅ Absturzrate: <0.5%

### Feature-Nutzung:
- ✅ Export-Nutzung: >60% der aktiven User
- ✅ Pausen-Tracking: >50% der User mit Pausen
- ✅ Authentifizierung: >70% der User aktivieren
- ✅ Benachrichtigungen: >40% aktivieren

### App Store Metriken:
- ✅ Bewertung: >4.5 Sterne
- ✅ Downloads: >1000 in ersten 30 Tagen
- ✅ Retention: >60% nach 7 Tagen, >40% nach 30 Tagen
- ✅ Deinstallationsrate: <10% nach 30 Tagen

---

## Timeline-Übersicht

| Woche | Milestone | Fokus | Key Deliverable |
|-------|-----------|-------|-----------------|
| 1-3 | 1 | Stabilisierung | Test-Abdeckung >80% |
| 4-7 | 2 | Export | TestFlight Release |
| 8-10 | 3 | Pausen | Must-Have Feature |
| 11-12 | 4 | Sicherheit | Authentifizierung |
| 13-15 | 5 | UX-Polish | Production Release |

---

## Nächste Schritte

### ✅ Erledigt (16.02.2026):
1. ✅ Duplizierte Header bereinigt
2. ✅ AppConfiguration.swift erstellt
3. ✅ AppStrings.swift für Lokalisierung erstellt
4. ✅ ErrorHandler.swift implementiert
5. ✅ HapticFeedback.swift implementiert
6. ✅ Export-Architektur erstellt (ExportOptions, ExportValidator, CSVExporter, PDFExporter, ExportManager)
7. ✅ Mail-Integration (MailComposerView, MailTemplates)
8. ✅ Share-Integration (ShareSheetView)
9. ✅ ExportView erstellt
10. ✅ Export-Button in ContentView integriert
11. ✅ Accessibility Labels hinzugefügt
12. ✅ **BUILD SUCCESSFUL** ✅

### Diese Woche:
1. [ ] Unit Tests für Shift-Logik schreiben
2. [ ] VoiceOver-Optimierung
3. [ ] Dynamic Type Support

### Nächste Woche:
1. [ ] CSV-Export vollständig implementieren (mit echten Shift-Daten)
2. [ ] PDF-Export mit echtem Layout
3. [ ] Test-Target erstellen

---

**Stand:** 16.02.2026
**Version:** 1.1
**Status:** In Entwicklung - Milestone 1 & 2 begonnen
**Build:** ✅ SUCCESS
