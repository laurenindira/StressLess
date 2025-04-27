//
//  HeartRateViewModel.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/25/25.
//
// medium.com/@kevinbryanreligion/the-most-straight-forward-tutorial-on-how-to-use-healthkit-for-swiftui-a59bce6b2e96
// medium.com/display-and-use-heart-rate-with-healthkit-on/display-and-use-heart-rate-with-healthkit-on-swiftui-for-watchos-2b26e29dc566

import Foundation
import HealthKit
import SwiftUI
import UserNotifications

class HeartRateViewModel: ObservableObject {
    @AppStorage("lastBPM") private var lastBPM: Int = 0
    
    @Published var bpm: Int = 0
    @Published var hrv: Double = 0.0 // in milliseconds
    @Published var heartRateHistory: [Int] = []
    
    private var healthStore = HKHealthStore()
    private let heartRateUnit = HKUnit(from: "count/min")
    
    let stressThreshold = 100 // change to bpm we decide

    init() {
        requestAuthorization()
        simulateFakeHeartRate()
    }

    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }

        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted.")
                self.startHeartRateQuery()
                self.fetchLatestHRV()
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    // heart rate
    private func startHeartRateQuery() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])

        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            _, samples, _, _, _ in
            guard let samples = samples as? [HKQuantitySample] else { return }

            DispatchQueue.main.async {
                self.process(samples)
            }
        }

        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: devicePredicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit,
            resultsHandler: updateHandler
        )

        query.updateHandler = updateHandler
        healthStore.execute(query)
    }
    
    // heart rate variability
    func fetchLatestHRV() {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            print("HRV type not available")
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)

        let query = HKStatisticsQuery(quantityType: hrvType, quantitySamplePredicate: predicate, options: .mostRecent) { _, result, error in
            guard let result = result,
                  let quantity = result.mostRecentQuantity() else {
                print("Could not fetch HRV: \(error?.localizedDescription ?? "No data")")
                return
            }

            let value = quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))

            DispatchQueue.main.async {
                self.hrv = value
                print("HRV: \(value) ms")
            }
        }

        healthStore.execute(query)
    }
    
    // threshold for heart rate
    private func process(_ samples: [HKQuantitySample]) {
        for sample in samples {
            let currentBPM = Int(sample.quantity.doubleValue(for: heartRateUnit))
            self.bpm = currentBPM
            self.lastBPM = currentBPM

            self.heartRateHistory.append(currentBPM)
            if self.heartRateHistory.count > 50 { // save the last 50 bpm, make sure that user stressed consistently
                self.heartRateHistory.removeFirst()
            }

            // Check if above threshold
            if currentBPM >= stressThreshold {
                print("Stress Alert: BPM = \(currentBPM)")
                //  TODO: add vibration/notification + display on watch
                NotificationManager.scheduleNotification()
            }
        }
    }
    
    // simulate fake heart rate + hrv
    private func simulateFakeHeartRate() {
        #if targetEnvironment(simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let fakeBPM = 120
            self.bpm = fakeBPM
            self.lastBPM = fakeBPM
            self.heartRateHistory.append(fakeBPM)

            print("Simulator: Fake BPM = \(fakeBPM)")

            let fakeHRV = 50.0
            self.hrv = fakeHRV
//            self.lastHRV = fakeHRV
//            self.hrvHistory.append(fakeHRV)

            print("Simulator: Fake HRV = \(fakeHRV) ms")

            if fakeBPM >= self.stressThreshold {
                NotificationManager.scheduleNotification()
            }
        }
        #endif
    }

}

