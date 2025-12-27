//
//  ColorPreviewView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 27.12.25.
//

import SwiftUI

struct ColorPreviewView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Option 1: Apple Green
                    ColorThemeCard(
                        title: "Option 1: Apple Green",
                        subtitle: "Subtil & Professional",
                        primary: .green,
                        secondary: .blue,
                        accent: .mint
                    )
                    
                    // Option 2: Professional Blue
                    ColorThemeCard(
                        title: "Option 2: Professional Blue",
                        subtitle: "Vertrauenswürdig & Ruhig",
                        primary: Color(hex: "#007AFF") ?? .blue,
                        secondary: Color(hex: "#32ADE6") ?? .cyan,
                        accent: .green
                    )
                    
                    // Option 3: Modern Indigo
                    ColorThemeCard(
                        title: "Option 3: Modern Indigo",
                        subtitle: "Kreativ & Premium",
                        primary: .indigo,
                        secondary: .purple,
                        accent: .green
                    )
                    
                    // Option 4: Orange Warmtöne ⭐ Deine Tendenz
                    ColorThemeCard(
                        title: "Option 4: Orange Warmtöne ⭐",
                        subtitle: "Energetisch & Freundlich",
                        primary: .orange,
                        secondary: Color(hex: "#FF6482") ?? .pink,
                        accent: .green
                    )
                }
                .padding()
            }
            .navigationTitle("Farbauswahl")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ColorThemeCard: View {
    let title: String
    let subtitle: String
    let primary: Color
    let secondary: Color
    let accent: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Titel
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Farb-Palette
            HStack(spacing: 12) {
                ColorSwatch(color: primary, label: "Primary")
                ColorSwatch(color: secondary, label: "Secondary")
                ColorSwatch(color: accent, label: "Accent")
            }
            
            Divider()
            
            // Beispiel: Aktiver Shift
            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(primary)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Frühschicht")
                        .font(.caption)
                        .foregroundStyle(primary)
                        .fontWeight(.semibold)
                    
                    Text("Heute, 08:00")
                        .font(.headline)
                    
                    Text("Läuft gerade...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("2.5 h")
                    .font(.headline)
                    .foregroundStyle(primary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Beispiel: Beendeter Shift
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(secondary)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spätschicht")
                        .font(.caption)
                        .foregroundStyle(secondary)
                        .fontWeight(.semibold)
                    
                    Text("Gestern, 14:00")
                        .font(.headline)
                    
                    Text("bis 22:00")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("8.0 h")
                    .font(.headline)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Beispiel: Button
            Button {
                // Nothing
            } label: {
                Label("EINSTEMPELN", systemImage: "play.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(primary)
                    .cornerRadius(12)
            }
            
            // Beispiel: Statistik Card
            VStack(spacing: 8) {
                HStack {
                    Text("Diese Woche")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("38.5 Std")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(accent)
                }
                
                // Mini Fortschrittsbalken
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(accent)
                            .frame(width: geo.size.width * 0.75)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("Überstunden")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("+2.5 Std")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(accent)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct ColorSwatch: View {
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ColorPreviewView()
}
