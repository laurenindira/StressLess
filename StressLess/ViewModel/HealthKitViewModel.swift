//
//  HealthKitViewModel.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import Foundation
import HealthKit

class HealthKitViewModel: ObservableObject {
    static let shared = HealthKitViewModel()
    
    @Published var healthStore = HKHealthStore()
    @Published var restingHeartRate: Double?
    @Published var heartRateVariability: Double?
    
    var errorMessage: String = ""
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let healthKitTypes: Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!]
        
        healthStore.requestAuthorization(toShare: [], read: healthKitTypes) { success, error in
            if success {
                print("SUCCESS: HealthKit authorization granted")
            } else {
                self.errorMessage = error?.localizedDescription ?? ""
                print("ERROR: HealthKit authorization failed - \(self.errorMessage)")
            }
        }
    }
    
    func fetchRestingHeartRate() async throws -> Double? {
        try await withCheckedThrowingContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let quantitySample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let bpm = quantitySample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                continuation.resume(returning: bpm)
            }
            
            healthStore.execute(query)
        }
    }
    
    func fetchHeartRateVariability() async throws -> Double? {
        try await withCheckedThrowingContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let quantitySample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let milliseconds = quantitySample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.secondUnit(with: .milli)))
                continuation.resume(returning: milliseconds)
            }
            healthStore.execute(query)
        }
    }
}
