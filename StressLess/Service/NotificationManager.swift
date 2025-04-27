//
//  NotificationManager.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/27/25.
//
// developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app

import Foundation
import UserNotifications

struct NotificationManager {

    static func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("SUCCESS: Authorization given")
            } else if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }

    static func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Take a deep breath"
        content.body = "Your heart rate is elevated. Take a moment to relax."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request)
    }

    static func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
