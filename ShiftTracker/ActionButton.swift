//
//  ActionButton.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 29.12.25.
//

//
//  ActionButton.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 28.12.25.
//

//
//  ActionButton.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 29.12.25.
//

import SwiftUI

struct ActionButton: View {
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isActive ? "stop.fill" : "play.fill")
                    .font(.title3)
                
                Text(isActive ? "AUSSTEMPELN" : "EINSTEMPELN")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isActive ? Color.red : Color.green)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
}

// Preview für schnelles Testing
#Preview {
    VStack {
        ActionButton(isActive: false, action: {})
        ActionButton(isActive: true, action: {})
    }
}
