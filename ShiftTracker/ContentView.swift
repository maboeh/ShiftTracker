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
    var activeShift: Shift? {
        shifts.first(where: {$0.endTime == nil })  }
    
    
    var body: some View {
      
        NavigationStack {
            List {
               
                ForEach(shifts) { shift in
                    HStack {  // 👈 Wrap alles in eine View!
                        if shift.endTime == nil {
                            Text("🟢 Aktiv \(shift.startTime.formatted(date: .omitted, time: .shortened))")
                        } else {
                            Text("\(shift.startTime.formatted(date: .omitted, time: .shortened)) - \(shift.endTime!.formatted(date: .omitted, time: .shortened)) (\(String(format: "%.1fh", shift.duration / 3600)))")
                        }
                    }
                }
                .onDelete(perform: deleteShifts)
            }
            .navigationTitle("My Shifts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button("\(activeShift == nil ? "Einstempeln" : "Ausstempeln")") {
                        if activeShift == nil {
                            // NEUEN Shift ERSTELLEN und zur DB hinzufügen!
                            let newShift = Shift(startTime: Date(), endTime: nil)
                            modelContext.insert(newShift)
                        } else {
                            // Existierenden Shift MODIFIZIEREN
                            activeShift!.endTime = Date()
                        }
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

