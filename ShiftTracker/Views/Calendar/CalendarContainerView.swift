//
//  CalendarContainerView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import SwiftUI

enum CalendarViewMode: String, CaseIterable {
    case month, week
}

struct CalendarContainerView: View {
    @State private var selectedDate: Date = Date()
    @State private var viewMode: CalendarViewMode = .month
    @State private var displayedMonth: Date = Date()
    @State private var showAddPlannedSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker(AppStrings.ansicht, selection: $viewMode) {
                    Text(AppStrings.monat).tag(CalendarViewMode.month)
                    Text(AppStrings.wocheAnsicht).tag(CalendarViewMode.week)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                switch viewMode {
                case .month:
                    CalendarMonthView(
                        selectedDate: $selectedDate,
                        displayedMonth: $displayedMonth
                    )
                case .week:
                    CalendarWeekView(
                        selectedDate: $selectedDate
                    )
                }

                Divider()

                CalendarDayDetailView(date: selectedDate)
            }
            .navigationTitle(AppStrings.kalender)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        ShiftPatternListView()
                    } label: {
                        Image(systemName: "repeat")
                    }
                    .accessibilityLabel(AppStrings.schichtMuster)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddPlannedSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(AppStrings.neueGeplanteSchicht)
                }
            }
            .sheet(isPresented: $showAddPlannedSheet) {
                NavigationStack {
                    PlannedShiftEditView(initialDate: selectedDate)
                }
            }
            .errorAlert()
        }
    }
}

#Preview {
    CalendarContainerView()
}
