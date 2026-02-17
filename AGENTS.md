# AGENTS.md - ShiftTracker Development Guide

This document provides guidelines for AI coding agents working on the ShiftTracker codebase.

## Project Overview

ShiftTracker is a native iOS app for tracking work shifts, built with SwiftUI and SwiftData. It targets shift workers in healthcare, hospitality, retail, and other industries with irregular working hours.

**Tech Stack:**
- SwiftUI for declarative UI
- SwiftData for local persistence
- MVVM architecture
- SF Symbols for icons

**Requirements:**
- iOS 17.6+
- Xcode 15.0+
- Swift 5.0

---

## Build/Lint/Test Commands

### Building

```bash
# Build the project (Debug)
xcodebuild -project ShiftTracker.xcodeproj -scheme ShiftTracker -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16'

# Build the project (Release)
xcodebuild -project ShiftTracker.xcodeproj -scheme ShiftTracker -configuration Release -destination 'platform=iOS Simulator,name=iPhone 16'

# Build for all simulators
xcodebuild -project ShiftTracker.xcodeproj -scheme ShiftTracker -destination 'generic/platform=iOS Simulator'
```

### Running Tests

```bash
# Run all tests (when tests exist)
xcodebuild test -project ShiftTracker.xcodeproj -scheme ShiftTracker -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test file
xcodebuild test -project ShiftTracker.xcodeproj -scheme ShiftTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ShiftTrackerTests/SpecificTestClass

# Run a single test method
xcodebuild test -project ShiftTracker.xcodeproj -scheme ShiftTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ShiftTrackerTests/SpecificTestClass/testMethodName
```

> **Note:** This project currently does not have a test target configured. When adding tests, create a new test target in Xcode.

### Linting & Static Analysis

```bash
# Swift compiler warnings are enabled by default
# Build with warnings as errors (strict mode)
xcodebuild -project ShiftTracker.xcodeproj -scheme ShiftTracker SWIFT_TREAT_WARNINGS_AS_ERRORS=YES

# Run static analyzer
xcodebuild -project ShiftTracker.xcodeproj -scheme ShiftTracker analyze -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Code Style Guidelines

### File Header

Every Swift file should have a header comment:

```swift
//
//  FileName.swift
//  ShiftTracker
//
//  Created by Author Name on DD.MM.YY.
//
```

### Imports

Order imports alphabetically, framework imports before local imports:

```swift
import SwiftUI
import SwiftData
```

### Naming Conventions

- **Types:** PascalCase (e.g., `ShiftDetailView`, `WeekStatsCard`)
- **Properties/Variables:** camelCase (e.g., `totalHours`, `shiftType`)
- **Functions:** camelCase, verb phrases (e.g., `toggleShift()`, `deleteShift()`)
- **Private helpers:** Mark with `private` modifier
- **Computed properties:** Use for derived values, place after stored properties

### Structs vs Classes

- **Views:** Always `struct` conforming to `View`
- **Data Models:** `class` with `@Model` macro for SwiftData
- **ViewModels:** `class` with `@Observable` (when needed)

### Property Order in Views

1. Property declarations (bindings, state, environment)
2. Computed properties
3. `body` property
4. Private functions

```swift
struct ExampleView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    
    private var isValid: Bool {
        item.name.isEmpty == false
    }
    
    var body: some View {
        // ...
    }
    
    private func save() {
        // ...
    }
}
```

### SwiftData Models

```swift
@Model
class Shift {
    var startTime: Date
    var endTime: Date?
    
    @Relationship(deleteRule: .nullify, inverse: \ShiftType.shifts)
    var shiftType: ShiftType?
    
    var duration: TimeInterval {
        // Computed from startTime/endTime
    }
    
    init(startTime: Date, endTime: Date? = nil) {
        self.startTime = startTime
        self.endTime = endTime
    }
}
```

### SwiftUI Patterns

- Use `@Query` for fetching SwiftData objects
- Use `@Bindable` for two-way binding with SwiftData models
- Use `@Environment(\.modelContext)` for database operations
- Use `@Environment(\.dismiss)` for navigation dismissal

```swift
@Query(sort: \Shift.startTime, order: .reverse) var shifts: [Shift]
@Environment(\.modelContext) private var modelContext
```

### Error Handling

- Use `try?` for non-critical operations (e.g., `try? modelContext.save()`)
- Handle errors explicitly for critical operations:

```swift
do {
    try modelContext.save()
} catch {
    print("Failed to save: \(error)")
}
```

### Formatting

- **Indentation:** 4 spaces (no tabs)
- **Blank lines:** Between logical sections
- **Line length:** Keep under 100 characters when practical
- **Trailing closure syntax:** Preferred for SwiftUI modifiers

### Spacing

```swift
HStack(spacing: 12) {
    // ...
}
.padding(.vertical, 8)
```

### UI Strings

- Use German language for user-facing strings
- Keep strings inline for simple cases
- Consider localization keys for production apps

```swift
Text("Noch keine Schichten")
Text("Läuft gerade...")
```

### Previews

Always include a preview for views:

```swift
#Preview {
    ContentView()
}

#Preview("With Parameters") {
    ShiftDetailView(shift: sampleShift)
}
```

---

## Architecture Guidelines

### MVVM Pattern

- **Model:** SwiftData classes (`Shift`, `ShiftType`)
- **View:** SwiftUI views (`ContentView`, `ShiftRow`, etc.)
- **ViewModel:** Currently using `@Bindable` directly; extract to dedicated ViewModel when logic becomes complex

### View Composition

Break down complex views into smaller components:

```
ContentView
├── WeekStatsCard
├── EmptyStateView
├── ShiftRow
│   └── (displays Shift data)
├── ShiftDetailView
└── ActionButton
```

### State Management

- Use `@State` for local view state
- Use `@Bindable` for model bindings
- Use `@Query` for automatic fetching
- Avoid `@ObservedObject` in favor of `@Bindable` with SwiftData

---

## Common Patterns in This Codebase

### Deleting Objects

```swift
private func deleteShift(_ shift: Shift) {
    withAnimation {
        modelContext.delete(shift)
        try? modelContext.save()
    }
}
```

### Computed Properties for Stats

```swift
private var weekStats: (totalHours: Double, overtime: Double) {
    // Calculate from queried shifts
    return (totalHours, overtime)
}
```

### Conditional UI Based on State

```swift
if shift.endTime == nil {
    Text("Läuft gerade...")
} else {
    Text("bis \(shift.endTime!.formatted(...))")
}
```

---

## Notes

- The app uses a 40-hour work week as the default target
- Week starts on Monday (`calendar.firstWeekday = 2`)
- Colors are stored as hex strings in SwiftData
- Use SF Symbols for all iconography
