//
//  ContentView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 14.12.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // @State = "Diese Variable kann sich ändern und UI updated sich automatisch"
    // [String] = Array von Texten
    @Query var shifts: [Shift]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                // ForEach = Schleife durch alle Shifts
                // id: \.self = Jeder String identifiziert sich selbst
                ForEach(shifts) { shift in
                    Text("\(shift.startTime, format: .dateTime)")
                }
                .onDelete(perform: deleteShifts)
            }
            .navigationTitle("My Shifts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add") {
                        // Fügt "Shift 1", "Shift 2", etc. hinzu
                        modelContext.insert(Shift(startTime: Date(), endTime: Date().addingTimeInterval(3600)))
                        
                    }
                }
                ToolbarItem(placement: .topBarLeading){
                    EditButton()
                }
                
                
                
                
            }
        }
    }
    private func deleteShifts(at offsets: IndexSet) {
        for index in offsets {
            
            modelContext.delete(shifts[index])
            
        }
        
    }
}

#Preview {
    ContentView()
}

