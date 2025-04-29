//
//  HealthKitViewModel.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import Foundation
import HealthKit
import UserNotifications
import Firebase
import FirebaseFirestore
import Combine


class HealthKitViewModel: ObservableObject {
    static let shared = HealthKitViewModel()
    
    //intial values
    @Published var healthStore = HKHealthStore()
    @Published var restingHeartRate: Double?
    @Published var heartRateVariability: Double?
    
    //session variables
    @Published var sessionHeartRate: Double = 0.0
    @Published var sessionhrv: Double = 0.0
    @Published var sessionDuration: TimeInterval = 0
    @Published var isSessionActive: Bool = false
    @Published var stressEvents: Int = 0
    @Published var heartRateValues: [Double] = []
    
    private var timer: Timer?
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var hrvQuery: HKAnchoredObjectQuery?
    private var sessionStart: Date?
    private var lastStressNotificationTime: Date? = nil
    
    //stress thresholds
    //TODO: fix thresholds based on scientific literature
    private let stressHeartRateThreshold: Double = 100.0
    private let stressHRVThreshold: Double = 30.0
    
    var errorMessage: String = ""
    var triggerStress: Bool = false
    
    private let db = Firestore.firestore()
    
    //simulated data
    @Published var isSimulationMode = true
    private var simulationCancellable: AnyCancellable?
    
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
    
//    func startSession() {
//        stressEvents = 0
//        heartRateValues = []
//        sessionStart = Date()
//        isSessionActive = true
//        
//        startTimer()
//        startHeartRateQuery()
//        startHRVQuery()
//    }
    
    // simulated start session data
    @MainActor func startSession() {
        stressEvents = 0
        heartRateValues = []
        sessionStart = Date()
        isSessionActive = true
        
        if isSimulationMode {
            startFakeSimulation()
        } else {
            startTimer()
            startHeartRateQuery()
            startHRVQuery()
        }
    }
    
//    func endSession() async {
//        stopTimer()
//        stopQueries()
//        isSessionActive = false
//        await saveSessionResults()
//        sessionDuration = 0
//    }
    
    // simulated end session data
    func endSession() async {
        if isSimulationMode {
            await stopFakeSimulation()
        } else {
            stopTimer()
            stopQueries()
        }
        
        isSessionActive = false
        await saveSessionResults()
        sessionDuration = 0
    }

    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.sessionDuration += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startHeartRateQuery() {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil)
        
        heartRateQuery = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] query, samplesOrNil, deletedObjectsOrNil, newAnchor, error in
            self?.handleHeartRateSamples(samplesOrNil)
        }
        
        heartRateQuery?.updateHandler = { [weak self] _, samplesOrNil, _, _, _ in
            self?.handleHeartRateSamples(samplesOrNil)
        }
        
        if let query = heartRateQuery {
            healthStore.execute(query)
        }
    }
    
    private func handleHeartRateSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        guard let sample = samples.last else { return }
        
        let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        DispatchQueue.main.async {
            self.sessionHeartRate = bpm
            self.heartRateValues.append(bpm)
            self.checkIfStressed()
        }
    }
    
    private func startHRVQuery() {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil)
        
        hrvQuery = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] query, samplesOrNil, deletedObjectsOrNil, newAnchor, error in
            self?.handleHRVSamples(samplesOrNil)
        }
        
        hrvQuery?.updateHandler = { [weak self] _, samplesOrNil, _, _, _ in
            self?.handleHRVSamples(samplesOrNil)
        }
        
        if let query = hrvQuery {
            healthStore.execute(query)
        }
    }
    
    private func handleHRVSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        guard let sample = samples.last else { return }
        
        let ms = sample.quantity.doubleValue(for: .secondUnit(with: .milli))
        DispatchQueue.main.async {
            self.sessionhrv = ms
            self.checkIfStressed()
        }
    }
    
    private func stopQueries() {
        if let queryHeartRate = heartRateQuery {
            healthStore.stop(queryHeartRate)
        }
        
        if let queryHRV = hrvQuery {
            healthStore.stop(queryHRV)
        }
    }
    
    private func checkIfStressed() {
        let isStressed = sessionHeartRate > stressHeartRateThreshold || sessionhrv < stressHRVThreshold
        if isStressed {
            stressEvents += 1
            print("stressed")
            
            let now = Date()
            // notify if more than x secs since the last notif
            if lastStressNotificationTime == nil || now.timeIntervalSince(lastStressNotificationTime!) > 30 {
                NotificationManager.shared.sendStressNotification()
                lastStressNotificationTime = now
                print("Stress notification triggered. Total: \(stressEvents)")
                self.triggerStress = true
            }
        }
//        else {
//            self.triggerStress = false
//        }
    }
    
    private func saveSessionResults() async {
        guard let start = sessionStart else { return }
        guard let userID = AuthViewModel.shared.user?.id else { return }
        
        let sessionRef = db.collection("allSessions").document(userID).collection("sessions").document()
        let sessionID = sessionRef.documentID
        
        let minHeartRate = heartRateValues.min() ?? 0
        let maxHeartRate = heartRateValues.max() ?? 0
        
        let sessionToAdd = Session(id: sessionID, userID: userID, sessionDate: start, sessionLength: sessionDuration, stressEvents: stressEvents, minHeartRate: minHeartRate, maxHeartRate: maxHeartRate)
        
        do {
            try sessionRef.setData(from: sessionToAdd)
            print("SUCCESS: Saved session to Firebase")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to save session - \(String(describing: errorMessage))")
        }
    }
    
    func deleteUserData(for userID: String) async {
        guard let user = AuthViewModel.shared.user else { return }
        
        do {
            let sessionRef = db.collection("allSessions").document(userID).collection("sessions").whereField("userID", isEqualTo: userID)
            let sessionsSnapshot = try await sessionRef.getDocuments()
            
            for doc in sessionsSnapshot.documents {
                try await doc.reference.delete()
            }
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to delete data - \(String(describing: errorMessage))")
        }
        
    }
    
    // call simulated data
    @MainActor private func startFakeSimulation() {
        sessionDuration = 0
        startTimer()
        
        FakeHealthData.shared.startSimulation()
        
        simulationCancellable = FakeHealthData.shared.$heartRate
            .combineLatest(FakeHealthData.shared.$hrv)
            .sink { [weak self] heartRate, hrv in
                self?.sessionHeartRate = heartRate
                self?.sessionhrv = hrv
                self?.heartRateValues.append(heartRate)
                self?.checkIfStressed()
            }
    }

    @MainActor private func stopFakeSimulation() {
        FakeHealthData.shared.stopSimulation()
        simulationCancellable?.cancel()
        simulationCancellable = nil
        stopTimer()
    }
    
    func fetchUserSessions() async -> [Session] {
        guard let userID = AuthViewModel.shared.user?.id else {
            print("ERROR: No user ID found in AuthViewModel.")
            return []
        }
        
        do {
            let snapshot = try await db.collection("allSessions")
                .document(userID)
                .collection("sessions")
                .order(by: "sessionDate", descending: false)
                .getDocuments()
            
            let sessions = snapshot.documents.compactMap { doc -> Session? in
                try? doc.data(as: Session.self)
            }
            
            print("SUCCESS: Loaded \(sessions.count) sessions from Firestore.")
            return sessions
        } catch {
            print("ERROR: Failed to fetch sessions: \(error.localizedDescription)")
            return []
        }
    }

}
