//
//  WeekStatsCard.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 28.12.25.
//

import SwiftUI

struct WeekStatsCard: View {
    let totalHours: Double
    let overtime: Double
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Diese Woche")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f Std", totalHours))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
            
            // Fortschrittsbalken
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Hintergrund (grau)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Fortschritt (grün)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
            
            // Überstunden
            HStack {
                Text("Überstunden")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%+.1f Std", overtime))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(overtime >= 0 ? .green : .orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
