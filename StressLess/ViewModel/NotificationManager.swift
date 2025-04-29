//
//  NotificationManager.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    static func requestNotificationAuthorization() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("SUCCESS: Authorization given")
                } else if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                }
            }
        }
    
    func sendStressNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Take a breather"
        content.body = "We've detected some increased stress. It might be time to take a break..."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("ERROR: Notification error - \(error.localizedDescription)")
            }
        }
    }
}
