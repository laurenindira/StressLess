//
//  HealthKitManager.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/24/25.
//
// medium.com/@kevinbryanreligion/the-most-straight-forward-tutorial-on-how-to-use-healthkit-for-swiftui-a59bce6b2e96

import Foundation
import HealthKit
import WidgetKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    var healthStore = HKHealthStore()

    @Published var stepCountToday: Int = 0
    @Published var thisWeekSteps: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0]

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        // this is to make sure User's Heath Data is available
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available!")
            return
        }

        // this is the type of data reading from Health
        let toReads = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ])

        // asking User's permission for their Health Data
        // note: toShare is set to nil since I'm not updating any data
        healthStore.requestAuthorization(toShare: nil, read: toReads) { success, error in
            if success {
                print("HealthKit authorization granted.")
                self.readStepCountToday()
                self.readStepCountThisWeek()
            } else {
                print("Authorization failed: \(String(describing: error))")
            }
        }
    }

    // TODO: don't need step counting, but will eventually change to HRV
    func readStepCountToday() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }

        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to read step count today: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }

            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            DispatchQueue.main.async {
                self.stepCountToday = steps
            }
        }

        healthStore.execute(query)
    }

    func readStepCountThisWeek() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            print("Failed to calculate the start date of the week.")
            return
        }

        guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
            print("Failed to calculate the end date of the week.")
            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfWeek,
            end: endOfWeek,
            options: .strictStartDate
        )

        let query = HKStatisticsCollectionQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfWeek,
            intervalComponents: DateComponents(day: 1)
        )

        query.initialResultsHandler = { _, result, error in
            guard let result = result else {
                print("Error retrieving weekly step count: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }

            result.enumerateStatistics(from: startOfWeek, to: endOfWeek) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    let steps = Int(quantity.doubleValue(for: HKUnit.count()))
                    let day = calendar.component(.weekday, from: statistics.startDate)

                    DispatchQueue.main.async {
                        self.thisWeekSteps[day] = steps
                    }
                }
            }
        }
        healthStore.execute(query)
    }
}
