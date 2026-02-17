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
    let targetHours: Double
    var shiftCount: Int = 0
    var totalBreakMinutes: Double = 0
    
    private var accessibilityDescription: String {
        let hoursText = String(format: "%.1f", totalHours)
        if overtime > 0 {
            return "\(AppStrings.dieseWoche): \(hoursText) \(AppStrings.std). \(AppStrings.ueberstunden): +\(String(format: "%.1f", overtime)) \(AppStrings.std)"
        } else {
            let remaining = targetHours - totalHours
            return "\(AppStrings.dieseWoche): \(hoursText) \(AppStrings.std). \(AppStrings.nochBis) \(Int(targetHours))h: \(String(format: "%.1f", remaining)) \(AppStrings.std)"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(AppStrings.dieseWoche)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f \(AppStrings.std)", totalHours))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
            .accessibilityHidden(true)
            
            if shiftCount > 0 {
                HStack {
                    Text("\(shiftCount) \(AppStrings.schichtenLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f Min. %@", totalBreakMinutes, AppStrings.pausenLabel))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                if overtime > 0 {
                    Text(AppStrings.ueberstunden)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "+%.1f \(AppStrings.std)", overtime))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                } else {
                    Text("\(AppStrings.nochBis) \(Int(targetHours))h")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f \(AppStrings.std)", targetHours - totalHours))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
}
