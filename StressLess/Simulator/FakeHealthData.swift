//
//  FakeHealthData.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/28/25.
//

import Foundation
import Combine

@MainActor
class FakeHealthData: ObservableObject {
    static let shared = FakeHealthData()
    
    @Published var heartRate: Double = 70
    @Published var hrv: Double = 50
    
    private var timer: Timer?
    @Published var isSimulating = false
    @Published var restingHeartRate: Double = 65
    @Published var averageHRV: Double = 55
    
    private let normalHeartRateRange = 65.0...80.0
    private let stressHeartRateRange = 100.0...140.0
    private let normalHRVRange = 40.0...70.0
    private let stressHRVRange = 20.0...40.0
    
    private var currentlyStressed = false
    
    private init() {}
    
    func startSimulation() {
        stopSimulation()
        isSimulating = true
        
        generateFakeBase()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.generateNextFakeData()
            }
        }
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
        isSimulating = false
    }
    
    private func generateNextFakeData() {
        if Bool.random() {
            currentlyStressed.toggle()
        }
        
        if currentlyStressed {
            heartRate = Double.random(in: stressHeartRateRange)
            hrv = Double.random(in: stressHRVRange)
        } else {
            heartRate = Double.random(in: normalHeartRateRange)
            hrv = Double.random(in: normalHRVRange)
        }
    }
    
    private func generateFakeBase() {
        restingHeartRate = Double.random(in: 60.0...70.0)
        averageHRV = Double.random(in: 45.0...65.0)
    }
}
