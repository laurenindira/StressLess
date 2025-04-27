//
//  WatchManager.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import Foundation
import WatchConnectivity

class WatchManager: NSObject, ObservableObject {
    @Published var isWatchPaired = false
    @Published var isWatchReachable = false
    @Published var activationState: WCSessionActivationState = .notActivated
    
    private var session: WCSession = {
        if WCSession.isSupported() {
            return WCSession.default
        } else {
            fatalError("ERROR: WCSession not supported on this device")
        }
    }()
    
    var errorMessage: String = ""
    
    override init() {
        
        super.init()
        session.delegate = self
        session.activate()
        
        //initalizing
        self.isWatchPaired = session.isPaired
        self.isWatchReachable = session.isReachable
        self.activationState = session.activationState
    }
    
    func sendMessageToWatch(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        if session.isReachable {
            session.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
        } else {
            self.errorMessage = "ERROR: Watch not reachable"
            print(self.errorMessage)
        }
    }
    
}

extension WatchManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchPaired = session.isPaired
            self.isWatchReachable = session.isReachable
            self.activationState = activationState
        }
    }
    
    //stubs for confomrance
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session did become inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
        print("Session deactivated. Reactivating...")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
    }
}
