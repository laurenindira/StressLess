//
//  HKSimulatorTests.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/28/25.
//
// github.com/StanfordBDHG/XCTHealthKit?tab=readme-ov-file
// swiftpackageindex.com/stanfordbdhg/xcthealthkit/1.1.2/documentation/xcthealthkit

import Foundation
import XCTest
import XCTHealthKit

final class HKSimulatorTests: XCTestCase {
    
    @MainActor func testSimulateHeartRateAndHRVChanges() throws {
        let app = XCUIApplication()
        app.launch()
        
        let healthApp = XCUIApplication.healthApp
        try app.handleHealthKitAuthorization()
        
        // heart rate and HRV
        let heartRates = [65, 70, 90, 130, 110, 85, 70]
//        let hrvValues = [65, 60, 50, 30, 35, 45, 60]
        
        for (_, bpm) in heartRates.enumerated() {
            try launchAndAddSamples(healthApp: healthApp, [
                .restingHeartRate(value: Double(bpm)),
//                .heartRate(value: Double(bpm)),
//                .heartRateVariability(value: Double(hrvValues[index]))
            ])
            
            sleep(5) // wait 5 seconds between samples
        }
    }
}



