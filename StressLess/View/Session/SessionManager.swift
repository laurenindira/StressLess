//
//  SessionManager.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/27/25.
//

import Foundation
import SwiftUI

class SessionManager: ObservableObject {
    @Published var isSessionActive: Bool = false
    @Published var elapsedSeconds: Int = 0
    
    private var timer: Timer?
    static let shared = SessionManager()
    
    // start study session
    func startSession() {
        guard !isSessionActive else { return }

        isSessionActive = true
        elapsedSeconds = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedSeconds += 1
        }
        
        HeartRateViewModel.shared.startMonitoring()
        print("Session started.")
    }

    // stop study session
    func stopSession() {
        guard isSessionActive else { return }
        
        timer?.invalidate()
        timer = nil

        isSessionActive = false
        
        HeartRateViewModel.shared.stopMonitoring()

        print("Session stopped.")
    }

    // Optional: Reset the session
    func resetSession() {
        stopSession()
        elapsedSeconds = 0
    }
}
