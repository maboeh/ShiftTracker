//
//  AppStrings.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Foundation

struct AppStrings {
    // MARK: - General
    static let appName = "ShiftTracker"
    static let welcomeBack = "Willkommen zurück"
    
    // MARK: - Navigation
    static let shiftOverview = "Schichtübersicht"
    
    // MARK: - Empty State
    static let noShifts = "Noch keine Schichten"
    static let tapEinstempeln = "Tippe auf 'Einstempeln' um deine erste Schicht zu starten"
    
    // MARK: - Actions
    static let einstempeln = "EINSTEMPELN"
    static let ausstempeln = "AUSSTEMPELN"
    static let loeschen = "Löschen"
    static let fertig = "Fertig"
    
    // MARK: - Statistics
    static let dieseWoche = "Diese Woche"
    static let ueberstunden = "Überstunden"
    static let nochBis = "Noch bis"
    static let std = "Std"
    
    // MARK: - Export
    static let export = "Export"
    static let exportTitle = "Daten exportieren"
    static let csvFormat = "CSV"
    static let pdfFormat = "PDF"
    static let dieseWocheExport = "Diese Woche"
    static let dieserMonat = "Dieser Monat"
    static let benutzerdefiniert = "Benutzerdefiniert"
    
    // MARK: - Shift Detail
    static let zeiten = "Zeiten"
    static let start = "Start"
    static let ende = "Ende"
    static let schichtArt = "Schicht-Art"
    static let keineAuswahl = "Keine Auswahl"
    static let info = "Info"
    static let dauer = "Dauer"
    static let schichtBearbeiten = "Shift bearbeiten"
    static let schichtLoeschen = "Shift löschen"
    static let shiftLaueftNoch = "Shift läuft noch"
    static let endeLiegtVorStart = "⚠️ Ende liegt vor Start"
    static let ungueltig = "Ungültig"
    static let stunden = "Stunden"
    
    // MARK: - Shift Row
    static let heute = "Heute"
    static let gestern = "Gestern"
    static let laeuftGerade = "Läuft gerade..."
    static let bis = "bis"
    
    // MARK: - Content View
    static let aelter = "Älter"

    // MARK: - Export View
    static let zeitraum = "Zeitraum"
    static let felder = "Felder"
    static let kopfzeilenEinfuegen = "Kopfzeilen einfügen"
    static let exportieren = "Exportieren"

    // MARK: - Breaks
    static let pause = "PAUSE"
    static let weiter = "WEITER"
    static let pausen = "Pausen"
    static let pauseHinzufuegen = "Pause hinzufügen"
    static let pauseBearbeiten = "Pause bearbeiten"
    static let keinePausen = "Keine Pausen"
    static let bruttoDauer = "Brutto"
    static let nettoDauer = "Netto"
    static let pausenzeit = "Pausenzeit"
    static let inPause = "In Pause..."
    static let pauseWarnung6h = "⚠️ Mind. 30 Min. Pause bei über 6 Std."
    static let pauseWarnung9h = "⚠️ Mind. 45 Min. Pause bei über 9 Std."

    // MARK: - PDF Preview
    static let pdfVorschau = "PDF Vorschau"

    // MARK: - Accessibility Hints
    static let hintDoppeltippen = "Doppeltippen zum Bearbeiten"
    static let hintSchichtLoeschen = "Löscht diese Schicht unwiderruflich"
    static let hintExportOeffnen = "Öffnet die Export-Optionen"
    static let hintSchichtBeenden = "Beendet die aktuelle Schicht"
    static let hintSchichtStarten = "Startet eine neue Schicht"
    static let hintPauseStarten = "Startet eine Pause"
    static let hintPauseBeenden = "Beendet die Pause und arbeitet weiter"

    // MARK: - Security
    static let sicherheit = "Sicherheit"
    static let appSperre = "App-Sperre"
    static let faceId = "Face ID"
    static let touchId = "Touch ID"
    static let biometrieVerwenden = "Biometrie verwenden"
    static let pinCode = "PIN-Code"
    static let pinEinrichten = "PIN einrichten"
    static let pinAendern = "PIN ändern"
    static let pinEntfernen = "PIN entfernen"
    static let pinEingeben = "PIN eingeben"
    static let pinBestaetigen = "PIN bestätigen"
    static let neuerPin = "Neuer PIN"
    static let pinStimmenNicht = "PINs stimmen nicht überein"
    static let pinFalsch = "PIN ist falsch"
    static let pinZuEinfach = "PIN ist zu einfach"
    static let pinMindestens = "Mindestens 4 Ziffern"
    static let pinGesperrt = "Zu viele Fehlversuche. Verwende %@."
    static let pinEntfernenFehler = "PIN konnte nicht entfernt werden"
    static let keychainFehler = "Sicherer Speicher nicht verfügbar"
    static let biometrieFehler = "Biometrie fehlgeschlagen. Versuche es erneut oder verwende den PIN."
    static let entsperren = "Entsperren"
    static let mitBiometrie = "Mit %@ entsperren"
    static let gesperrt = "Gesperrt"
    static let pauseAusserhalbSchicht = "Pause liegt außerhalb der Schichtzeit"

    // MARK: - Errors
    static let errorTitle = "Fehler"
    static let exportFailed = "Export fehlgeschlagen"
    static let saveFailed = "Speichern fehlgeschlagen"
    static let noDataToExport = "Keine Daten zum Exportieren"
}
