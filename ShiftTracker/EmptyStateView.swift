//
//  EmptyStateView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 30.12.25.
//

//
//  EmptyStateView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 29.12.25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            // Haupttext
            Text("Noch keine Schichten")
                .font(.title3)
                .fontWeight(.semibold)
            
            // Hilfstext
            Text("Tippe auf 'Einstempeln' um deine erste Schicht zu starten")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    EmptyStateView()
}
