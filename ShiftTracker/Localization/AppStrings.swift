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

    // MARK: - Settings
    static let einstellungen = "Einstellungen"
    static let arbeitszeit = "Arbeitszeit"
    static let wochenStunden = "Wochenstunden"
    static let wochenStundenInfo = "Ziel-Wochenstunden für die Überstundenberechnung"
    static let verwaltung = "Verwaltung"
    static let schichttypen = "Schichttypen"
    static let ueberApp = "Über die App"
    static let version = "Version"
    static let schichttypBearbeiten = "Schichttyp bearbeiten"
    static let neuerSchichttyp = "Neuer Schichttyp"
    static let name = "Name"
    static let farbe = "Farbe"
    static let keineSchichttypen = "Keine Schichttypen"
    static let schichttypHinzufuegen = "Schichttyp hinzufügen"
    static let zugewieseneSchichten = "Zugewiesene Schichten"
    static let speichern = "Speichern"
    static let schichttypLoeschen = "Schichttyp löschen"
    static let schichttypLoeschenInfo = "Zugewiesene Schichten werden auf 'Keine Auswahl' gesetzt."

    // MARK: - Statistics & Charts
    static let statistiken = "Statistiken"
    static let keineStatistiken = "Keine Statistiken"
    static let keineStatistikenInfo = "Starte Schichten um Statistiken zu sehen"
    static let monatsUebersicht = "Monatsübersicht"
    static let jahresUebersicht = "Jahresübersicht"
    static let stundenProWoche = "Stunden pro Woche"
    static let stundenProMonat = "Stunden pro Monat"
    static let zusammenfassung = "Zusammenfassung"
    static let gesamtStunden = "Gesamtstunden"
    static let durchschnitt = "Durchschnitt"
    static let anzahlSchichten = "Anzahl Schichten"
    static let woche = "Woche"
    static let monat = "Monat"

    // MARK: - Earnings
    static let verdienstrechner = "Verdienstrechner"
    static let stundenlohn = "Stundenlohn"
    static let stundenlohnInfo = "Brutto-Stundenlohn für Verdienstberechnung"
    static let verdienst = "Verdienst"
    static let verdienstDieseWoche = "Diese Woche"
    static let verdienstDieserMonat = "Dieser Monat"
    static let verdienstDiesesJahr = "Dieses Jahr"

    // MARK: - Notifications
    static let benachrichtigungen = "Benachrichtigungen"
    static let pausenErinnerung = "Pausen-Erinnerung"
    static let pausenErinnerungInfo = "Erinnert nach 6h ohne ausreichende Pause"
    static let schichtErinnerung = "Schicht-Erinnerung"
    static let schichtErinnerungInfo = "Erinnert nach einer bestimmten Schichtdauer"
    static let erinnerungNach = "Erinnern nach"
    static let benachrichtigungenAktivieren = "Benachrichtigungen aktivieren"
    static let pauseErinnerungTitel = "Pause machen!"
    static let pauseErinnerungText = "Du arbeitest seit über 6 Stunden. Gesetzliche Pause einlegen."
    static let schichtErinnerungTitel = "Schicht-Erinnerung"
    static let schichtErinnerungText = "Deine Schicht läuft seit %@ Stunden."

    // MARK: - Onboarding
    static let weiter2 = "Weiter"
    static let losgehts = "Los geht's"
    static let ueberspringen = "Überspringen"
    static let onboardingTitel1 = "Willkommen bei ShiftTracker"
    static let onboardingText1 = "Erfasse deine Arbeitszeiten einfach und schnell."
    static let onboardingTitel2 = "Pausen & Compliance"
    static let onboardingText2 = "Automatische Pausen-Überwachung nach deutschem Arbeitsrecht."
    static let onboardingTitel3 = "Export & Statistiken"
    static let onboardingText3 = "Exportiere als CSV oder PDF und behalte den Überblick."
    static let onboardingTitel4 = "Sicherheit"
    static let onboardingText4 = "Schütze deine Daten mit Face ID, Touch ID oder PIN."

    // MARK: - Help
    static let hilfe = "Hilfe"
    static let faqSchichtStarten = "Wie starte ich eine Schicht?"
    static let faqSchichtStartenAntwort = "Tippe auf den grünen 'EINSTEMPELN' Button am unteren Bildschirmrand."
    static let faqPauseMachen = "Wie mache ich eine Pause?"
    static let faqPauseMachenAntwort = "Während einer aktiven Schicht erscheint ein gelber 'PAUSE' Button. Tippe darauf um eine Pause zu starten."
    static let faqFarben = "Was bedeuten die Farben?"
    static let faqFarbenAntwort = "Grün = Einstempeln, Gelb = Pause starten, Orange = Pause beenden (Weiter), Rot = Ausstempeln."
    static let faqExport = "Wie exportiere ich meine Daten?"
    static let faqExportAntwort = "Tippe auf das Teilen-Symbol in der oberen rechten Ecke. Du kannst zwischen CSV und PDF wählen."
    static let faqPausenWarnung = "Was ist die Pausen-Warnung?"
    static let faqPausenWarnungAntwort = "Nach deutschem Arbeitsrecht (ArbZG §4) musst du bei über 6h Arbeit mindestens 30 Min. Pause machen, bei über 9h mindestens 45 Min."
    static let faqWochenstunden = "Wie ändere ich meine Wochenstunden?"
    static let faqWochenstundenAntwort = "Gehe zu Einstellungen → Arbeitszeit → Wochenstunden und passe den Wert an."
    static let faqSicherheit = "Wie sichere ich die App?"
    static let faqSicherheitAntwort = "Unter Einstellungen → Sicherheit kannst du Face ID, Touch ID oder einen PIN einrichten."

    // MARK: - Auto-Lock
    static let autoLockVerzoegerung = "Sperre nach"
    static let sofort = "Sofort"

    // MARK: - Privacy
    static let onboardingTitel5 = "Datenschutz"
    static let onboardingText5 = "Deine Daten bleiben auf deinem Gerät. Kein Cloud-Upload, kein Tracking, keine Werbung."
    static let datenschutzZustimmung = "Mit dem Start stimmst du der lokalen Datenverarbeitung zu."

    // MARK: - Encryption
    static let verschluesselt = "Verschlüsselt exportieren"
    static let passwort = "Passwort"
    static let passwortBestaetigen = "Passwort bestätigen"
    static let passwoerterStimmenNicht = "Passwörter stimmen nicht überein"

    // MARK: - Templates
    static let vorlagen = "Vorlagen"
    static let neueVorlage = "Neue Vorlage"
    static let ausVorlage = "Aus Vorlage"
    static let startzeit = "Startzeit"
    static let standardDauer = "Dauer"
    static let vorlageAnwenden = "Schicht starten"

    // MARK: - Extended Notifications
    static let vergessensAusstempeln = "Vergessenes Ausstempeln"
    static let vergessensAusstempelnInfo = "Warnung nach 10h ohne Ausstempeln"
    static let wochenbericht = "Wochenbericht"
    static let wochenberichtInfo = "Zusammenfassung jeden Freitag um 17:00"
    static let vergessensAusstempelnTitel = "Noch eingestempelt!"
    static let vergessensAusstempelnText = "Deine Schicht läuft seit über 10 Stunden. Vergessen auszustempeln?"
    static let wochenberichtTitel = "Wochenbericht"
    static let wochenberichtText = "Schau dir deine Arbeitsstunden dieser Woche an."

    // MARK: - Export History
    static let letzteExporte = "Letzte Exporte"
    static let keineExporte = "Noch keine Exporte"

    // MARK: - Week Stats Extended
    static let schichtenLabel = "Schichten"
    static let pausenLabel = "Pausen"

    // MARK: - Per-Type Wages
    static let typSpezifischerLohn = "Stundenlohn (optional)"
    static let standardLohn = "Standard"
    static let aufschluesselungNachTyp = "Nach Schichttyp"

    // MARK: - Errors
    static let errorTitle = "Fehler"
    static let exportFailed = "Export fehlgeschlagen"
    static let saveFailed = "Speichern fehlgeschlagen"
    static let noDataToExport = "Keine Daten zum Exportieren"
}
