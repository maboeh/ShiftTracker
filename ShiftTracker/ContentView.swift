//
//  ContentView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 14.12.25.
//

import SwiftUI

struct ContentView: View {
    // @State = "Diese Variable kann sich ändern und UI updated sich automatisch"
    // [String] = Array von Texten
    @State private var shifts: [String] = []
    
    var body: some View {
        NavigationStack {
            List {
                // ForEach = Schleife durch alle Shifts
                ForEach(shifts, id: \.self) { shift in
                    Text(shift)
                }
            }
            .navigationTitle("My Shifts")
            .toolbar {
                Button("Add") {
                    // Fügt "Shift 1", "Shift 2", etc. hinzu
                    shifts.append("Shift \(shifts.count + 1)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

