//
//  ColorExtensionTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 16.02.26.
//

import XCTest
import SwiftUI
@testable import ShiftTracker

final class ColorExtensionTests: XCTestCase {
    
    // MARK: - Valid Hex Color Tests
    
    func testValidHexColor() {
        let color = Color(hex: "#007AFF")
        
        XCTAssertNotNil(color, "Valid hex should create a color")
    }
    
    func testValidHexColorWithoutHash() {
        let color = Color(hex: "007AFF")
        
        XCTAssertNotNil(color, "Valid hex without hash should create a color")
    }
    
    func testBlackHexColor() {
        let color = Color(hex: "#000000")
        
        XCTAssertNotNil(color, "Black hex should create a color")
    }
    
    func testWhiteHexColor() {
        let color = Color(hex: "#FFFFFF")
        
        XCTAssertNotNil(color, "White hex should create a color")
    }
    
    func testRedHexColor() {
        let color = Color(hex: "#FF0000")
        
        XCTAssertNotNil(color, "Red hex should create a color")
    }
    
    func testGreenHexColor() {
        let color = Color(hex: "#00FF00")
        
        XCTAssertNotNil(color, "Green hex should create a color")
    }
    
    func testBlueHexColor() {
        let color = Color(hex: "#0000FF")
        
        XCTAssertNotNil(color, "Blue hex should create a color")
    }
    
    // MARK: - Invalid Hex Color Tests
    
    func testInvalidHexColor() {
        let color = Color(hex: "INVALID")
        
        XCTAssertNil(color, "Invalid hex should return nil")
    }
    
    func testEmptyHexColor() {
        let color = Color(hex: "")
        
        XCTAssertNil(color, "Empty hex should return nil")
    }
    
    func testTooShortHexColor() {
        let color = Color(hex: "X")
        
        XCTAssertNil(color, "Invalid hex should return nil")
    }
    
    func testHexWithSpaces() {
        let color = Color(hex: " 007AFF ")
        
        XCTAssertNotNil(color, "Hex with spaces should be trimmed and work")
    }
    
    // MARK: - ShiftType Color Tests
    
    func testShiftTypeColorConversion() {
        let shiftType = ShiftType(name: "Test", colorHex: "#FF9500")
        
        let color = shiftType.color
        
        // Color should be created without crashing
        XCTAssertNotNil(color, "ShiftType color should be created from hex")
    }
    
    func testShiftTypeWithInvalidHex() {
        let shiftType = ShiftType(name: "Test", colorHex: "INVALID")
        
        // Should fallback to blue
        let color = shiftType.color
        
        XCTAssertNotNil(color, "ShiftType color should fallback to blue for invalid hex")
    }
}
