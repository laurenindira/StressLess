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

class HeartRateViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    private let heartRateUnit = HKUnit(from: "count/min")

    @Published var bpm: Int = 0
    @Published var hrv: Double = 0.0 // in milliseconds

    init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }

        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let typesToRead: Set = [heartRateType]

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
                if let sample = samples.last {
                    let value = sample.quantity.doubleValue(for: self.heartRateUnit)
                    self.bpm = Int(value)
                }
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

        let query = HKStatisticsQuery(quantityType: hrvType, quantitySamplePredicate: predicate, options: .discreteMostRecent) { _, result, error in
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

}

